require 'active_support/core_ext'
require 'pleiades/core/command/routing/route_refine'

module Pleiades
  module Command
    module Routing
      # ブロック付きメソッド郡。
      #
      # イベントメソッドに渡すキーワード引数を、ネストしたリソースとしてまとめて実行する。
      #
      module NestBlocks
        extend ActiveSupport::Concern
        include Pleiades::Command::Routing::RouteRefine

        # スコープをネストする。
        #
        # ## メソッド呼び出し時のメソッド名による処理の違い
        # scope, scope_append
        # 引数を後方追加する
        #
        # scope_unshift
        # 引数を前方追加する
        #
        # ## EXAMPLE(単一リソースのネスト)
        # ### 使用しない
        # postback scope :hoge, action: :fuga
        # postback scope :hoge, action: :piyo
        #
        # ### 使用する
        # scope :hoge do
        #   postback action: :fuga
        #   postback action: :piyo
        # end
        #
        # ## EXAMPLE(複数リソースのネスト)
        # ### 使用しない
        # postback scope :hoge, action: :piyo
        # postback scope :fuga, action: :piyo
        #
        # ### 使用する
        # scope :hoge, :fuga do
        #   postback action: :piyo
        # end
        #
        def scope(*scopes, &block)
          scopes.flatten.map { |scp| nest_block __callee__, scp, &block }
        end
        alias :scope_append scope
        alias :scope_unshift scope

        # アクションをネストする。
        #
        # EXAMPLE
        # ## 使用しない
        # postback scope :hoge, action: :piyo
        # postback scope :fuga, action: :piyo
        #
        # ## 使用する
        # action :piyo do
        #   postback scope :hoge
        #   postback scope :fuga
        # end
        #
        # ## EXAMPLE(単一リソースのネスト)
        # ### 使用しない
        # postback scope :hoge, action: :piyo
        # postback scope :fuga, action: :piyo
        #
        # ### 使用する
        # action :piyo do
        #   postback scope :hoge
        #   postback scope :fuga
        # end
        #
        # ## EXAMPLE(複数リソースのネスト)
        # ### 使用しない
        # postback scope :piyo, action: :hoge
        # postback scope :piyo, action: :fuga
        #
        # ### 使用する
        # action :hoge, :fuga do
        #   postback scope: :piyo
        # end
        #
        def action(*actions, &block)
          actions.flatten.map { |act| nest_block __method__, act, &block }
        end

        # Concernsをネストしたリソースに適用する。
        #
        # concern HogeModule do
        #   postback # => HogeModule が include される
        #   concern FugaModule do
        #     postback # => HogeModule, FugaModule が include される
        #   end
        # end
        #
        def concern(*concerns, &block)
          nest_block __method__, concerns, &block
        end

        # コマンドクラスへの呼び出すメソッド名をネストしたリソースに適用する。
        #
        # ## EXAMPLE
        # ### 使用しない
        # postback scope :hoge, action: :fuga, method: :greet
        # # => Hoge::Fuga#greet が実行される。
        #
        # postback scope :hoge, action: :piyo, method: :greet
        # # => Hoge::Piyo#greet が実行される
        #
        # ### 使用する
        # method: :greet do
        #   postback scope :hoge, action: :fuga
        #   postback scope :hoge, action: :piyo
        # end
        #
        alias :_method_ method
        def method(method_name, &block)
          if block_given?
            nest_block __method__, method_name, &block
          else
            _method_(method_name)
          end
        end

        # 複数のネストメソッドを呼び出す。
        #
        # EXAMPLE
        # ## 使用しない
        #
        # scope :hoge do
        #   action :fuga do
        #     postback
        #   end
        # end
        #
        # ## 使用する
        # nest_blocks scope: :hoge, action: :fuga do
        #   postback
        # end
        #
        # @param [Hash] key: ネストメソッド名, val: 引数
        #
        def nest_blocks(**keywords, &block)
          validate_event_keywords(keywords.deep_dup.merge(type: ''))

          nested_options = make_nested_options(keywords)

          return if nested_options == false

          nested_options.each do |opt|
            nest(@options.deep_dup.merge(opt), &block)
          end
        end

        private

        def make_nested_options(keywords)
          nested_options =
            keywords.each_pair
                    .each_with_object([[self]]) do |(method_name, arg), arr|
                      routers = arr.last
                      break if routers.include?(false)

                      arr << nest_routers(routers) { method(method_name).call(arg) }.flatten
                    end.last

          nested_options ? nested_options.map(&:options) : false
        end

        def nest_routers(routers, &proc)
          routers.map do |router|
            nest_router = Array.wrap(nest(router.options.deep_dup, &proc))

            break if nest_router.include?(false)

            nest_router
          end || [false]
        end

        def callable_nest_methods
          reject_methods = %i[nest_blocks _method_]

          Pleiades::Command::Routing::NestBlocks.public_instance_methods.without(*reject_methods)
        end

        def default_options
          {
            scope: [],
            action: '',
            method: '',
            concern: []
          }.merge(Pleiades::Config.router_default_option)
        end

        def nest_block(method_name, context, &block)
          @_options = __send__ "merge_#{method_name}", context
          @_self = Pleiades::Command::Router.new(@_options)

          block_given? ? @_self.instance_eval(&block) : @_self
        end

        def merge_scope(context)
          operator =
            case __callee__
            when /^merge_scope(_append)?$/
              :append
            when /^merge_scope_unshift$/
              :unshift
            end

          __merge__ ->(option) { option[:scope].__send__ operator, context }
        end
        alias :merge_scope_append merge_scope
        alias :merge_scope_unshift merge_scope

        def merge_action(action)
          __merge__ ->(option) { option[:action] = action }
        end

        def merge_concern(concerns)
          __merge__ ->(option) { option[:concern].concat(concerns).flatten }
        end

        def merge_method(method)
          __merge__ ->(option) { option[:method] = method }
        end

        def __merge__(proc)
          dup_options = @options.deep_dup
          proc.call(dup_options)
          dup_options
        end
      end
    end
  end
end
