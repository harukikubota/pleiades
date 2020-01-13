require 'pleiades/core/command/routing/route_refine'

module Pleiades
  module Command
    class RoutingProxy
      include Pleiades::Command::Routing::RouteRefine

      class << self
        def routing(&block)
          @_ = new(@event)

          block_given? ? @_.instance_eval(&block) : @_.default_routing
        end

        # 読み込む router_files を決める。
        #
        # @param [Line::Bot::Event] Eventクラス
        #
        # @return [Array<Pathname, ...>] 読み込むファイル一覧
        #
        def collect_router_file(event)
          @event = event
          proxy_exists? ? load(proxy_file) : routing

          collect!
        end

        private

        def proxy_exists?
          FileTest.exist?(proxy_file)
        end

        def proxy_file
          Pleiades::Constants::File::ROUTING_PROXY
        end

        def collect!
          @_.routers
        end
      end

      attr_reader :routers, :mount_pairs

      def initialize(event)
        @event = event
        @routers = []
        @mount_pairs = {}

        mount default: Pleiades::Constants::File::CONFIG_DIR_PATH
      end

      def default_routing
        add default_router
      end

      def add(router_name, mnt_key: :default)
        no_keyword_err = lambda { |key|
          <<~MES
            from #{__FILE__}:#{__LINE__ - 1}:in `#{__method__}`:
              Unmounted key `#{key}`. Please call `mount #{key}: 'path/to/router'` before `#{__method__}`.
          MES
        }
        dir = @mount_pairs.fetch(mnt_key) { |key| raise no_keyword_err.call(key) }

        @routers << "#{dir}/#{router_name}.rb"
      end

      # `add`で指定するキーワードを登録する。
      #
      # @param [symbol_name: path, ...]
      #   symbol_name : キーワード
      #   path        : プロジェクトホームからの相対パスまたは、絶対パス
      #
      # ## EXAMPLE
      # mount hoge: 'path/to/hoge'
      # add :fuga, mnt: :hoge
      # # => path/to/hoge/fuga.rb
      #
      def mount(**paths)
        validate_mount_keys(paths.keys)

        paths.each_pair do |symbol, path|
          @mount_pairs.store(symbol, path =~ %r{(\S+)/$} ? $1 : path)
        end
      end

      def unmount(*mnt_symbols)
        return @mount_pairs.clear && nil if mnt_symbols.include?(:all)

        warn = ->(key) { "\nWarning from #{__FILE__}:#{__LINE__ - 3}:in `#{__method__}`: `#{key}` is unmounted." }

        mnt_symbols.each do |symbol|
          @mount_pairs.delete(symbol) { |sym| puts warn.call(sym) }
        end
      end

      def unmount_all
        unmount :all
      end

      def default_router
        :router
      end

      private

      def validate_mount_keys(keys)
        keys.each do |key|
          raise "`#{key}` is reserved words. Please specify another key name." if mount_reserved_word?(key)

          raise "`#{key}` is already mounted." if mounted?(key)
        end
        true
      end

      def mount_reserved_word?(word)
        %i[all].include?(word.to_sym)
      end

      def mounted?(key)
        @mount_pairs.key?(key)
      end
    end
  end
end
