module Pleiades
  module Command
    module Routing
      module Validator
        extend ActiveSupport::Concern

        private

        # `match` の引数を検証する
        #
        # @param [Hash] match_keywords
        #
        # @raise 無効なイベント名が存在する場合に送出される
        #
        # @return [true] 入力値が妥当な場合
        #
        def validate_match_keywords(match_keywords)
          match_keywords.fetch(:via) do |_|
            raise ArgumentError, "Make sure to specify keyword `via:' in the `match' method."
          end

          match_keywords[:via].each_key do |event_name|
            no_event = -> { raise "Unexpected event method `#{event_name}' specified in keyword `via:'." }
            event_types.find(no_event) { |event| event_name.to_s == event }
          end

          true
        end

        # イベントメソッドの引数を検証する
        #
        # @param [Hash] keywords
        #
        # @raise [ArgumentError] 無効なキーワード名が存在する場合
        #
        # @return [True] 入力値が妥当な場合
        #
        def validate_event_keywords(keywords)
          @_keywords = keywords.deep_dup
          event_name = @_keywords.delete(:type)

          event_specify_keywords = per_event_specify_keywords(event_name)

          @_keywords.keys.each do |key|
            next if event_specify_keywords.include?(key)

            raise ArgumentError, <<~MES
              #{__FILE__}:#{__LINE__}:in `#{__method__}'
              #{event_name} event, key `#{key}' cannot be specified.
            MES
          end
          true
        end

        def per_event_specify_keywords(event_name)
          event_name = event_name.to_sym

          commons = callable_nest_methods
          per_events =
            {
              text: %i[pattern],
              sticker: %i[package_id sticker_id]
            }

          extract_keywords = per_events[event_name]

          extract_keywords ? commons.concat(extract_keywords) : commons
        end
      end
    end
  end
end
