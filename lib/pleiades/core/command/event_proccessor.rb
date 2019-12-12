module Pleiades
  module Command
    module EventProccessor
      extend ActiveSupport::Concern

      def method_missing(method, **args)
        return super unless event_types.include?(method.to_s)

        args.merge! type: method.to_s

        exe_event_method args
      end

      private

      def event_types
        Pleiades::Constants::Events::TYPES
      end

      def exe_event_method(args)
        procs(args[:type]).each_with_object([true]) do |proc, arr|
          next unless arr.last

          arr << proc.call(args)
        end
      end

      def procs(method_name)
        proc_method_names = %i[
                              route_unfixid?
                              matching_events?
                              route_fix!
                            ]

        proc_method_names.insert(2, :"#{method_name}_judge_method") if judge_method_defined?(method_name)
        proc_method_names.map { |n| method(n) }
      end

      def route_unfixid?(_args)
        !Router.path_found?
      end

      def matching_events?(args)
        @event.type == args[:type]
      end

      def route_fix!(args)
        Router.path = normalize_path args[:scope], args[:action]
      end

      def judge_method_defined?(method)
        private_methods.include?(:"#{method}_judge_method")
      end

      def text_judge_method(args)
        decision_operator =
          case args[:pattern]
          when Regexp
            '=~'
          when String
            '=='
          end
        eval("args[:pattern] #{decision_operator} @event.text")
      end

      def sticker_judge_method(args)
        convert_to_reg = -> (id) do
          case id
          when String, Integer
            return '*'.eql?(id) ? /^\d+$/ : /^#{id}$/
          when Array
            return /^#{id.join('|')}$/
          end
          id
        end

        p, s = @event.sticker_ids
        convert_to_reg.(args[:package_id]) =~ p &&
          convert_to_reg.(args[:sticker_id]) =~ s
      end

      def postback_judge_method(args)
        normalize_path(args[:scope], args[:action]) == @event.action
      end
    end
  end
end
