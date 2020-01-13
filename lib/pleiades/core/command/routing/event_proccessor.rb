require 'pleiades/core/command/routing/event_judge_methods'

module Pleiades
  module Command
    module Routing
      module EventProccessor
        extend ActiveSupport::Concern
        prepend Pleiades::Command::Routing::EventJudgeMethods

        # match 複数のイベントメソッドを実行する。
        #
        # EXAMPLE(以下のmatchなし、matchありは同義)
        #
        # ## matchなし
        # scope 'line' do
        #   action :greet do
        #     text pattern: 'Hello, world'
        #     sticker package_id: '1', sticker_id: '1'
        #   end
        # end
        #
        # ## matchあり
        # match(
        #   via: {
        #     text: {
        #       pattern: 'Hello, world'
        #     },
        #     sticker: {
        #       package_id: '1',
        #       sticker_id: '1'
        #     }
        #   },
        #   scope: 'line',
        #   action: :greet
        # )
        #
        def match(**args)
          validate_match_keywords(args)

          args.delete(:via).each_pair do |event, val|
            __send__ event, merge_from_match(val, args)
          end
        end

        # イベントクラス名をリフレクションして、イベントメソッドを実行する。
        #
        # EXAMPLE
        # ## 使用しない
        # text pattern: 'Hello'
        #
        # ## 使用する
        # p __event_name__ # => "text"
        # event pattern: 'Hello'
        #
        def event(**keywords)
          __send__ __event_name__.to_sym, keywords
        end

        private

        def method_missing(method, *args, &block)
          return super unless event_types.include?(method.to_s)

          exe_event_method(args.inject(&:merge).merge(type: method))
        end

        def respond_to_missing?(method, *args, &block)
          event_types.include?(method.to_s) || super
        end

        def exe_event_method(args)
          on_execute = validate_event_keywords(args) && event_executable?(args)
          return unless on_execute

          method_name = args[:type]

          if judge_method_defined?(method_name)
            return unless method(judge_method(method_name)).call(args)
          end

          route_fix!(args)
        end

        def event_executable?(args)
          exe_conditions = [route_unfixid?, matching_events?(args[:type])]

          exe_conditions << callable_talk_type?([args[:talk_type]]) if args.key?(:talk_type)

          exe_conditions.all?
        end

        def merge_from_match(via, arg)
          arg.merge(via) do |key, a_val, v_val|
            case key
            when :scope, :concern
              [a_val, v_val].flatten
            else
              v_val
            end
          end
        end

        def event_types
          Pleiades::Constants::Events::TYPES
        end

        def route_unfixid?
          !Router.path_found?
        end

        def matching_events?(method_name)
          __event_name__ == method_name.to_s
        end

        def route_fix!(args)
          Pleiades::Command::Router.path_info =
            Pleiades::Command::Routing::Result.create(@options, args)
        end
      end
    end
  end
end
