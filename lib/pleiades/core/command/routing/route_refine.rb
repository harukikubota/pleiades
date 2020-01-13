module Pleiades
  module Command
    module Routing
      module RouteRefine
        # 指定したイベントの時のみブロックを実行する
        #
        # ## EXAMPLE
        # only_events :postback do
        #   event scope :hoge, action: :fuga
        #   # => Hoge::Fuga を postbackイベントとして実行する
        # end
        #
        def only_events(*events, &block)
          return false unless callable_event_type?(events)

          return self unless block_given?

          instance_eval(&block)
        end

        # 指定したトークタイプの時のみブロックを実行する
        #
        # ## EXAMPLE
        # talk_type :user do
        #   p @event.source.type # => "user"
        #   postback scope :hoge, action: :fuga
        # end
        #
        def talk_type(*talk_types, &block)
          return false unless callable_talk_type?(talk_types)

          return self unless block_given?

          instance_eval(&block)
        end

        private

        def callable_talk_type?(types)
          types.map(&:to_s).include?(@event.source.type)
        end

        def callable_event_type?(types)
          types.map(&:to_s).include?(__event_name__)
        end
      end
    end
  end
end
