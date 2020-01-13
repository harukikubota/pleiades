module Pleiades
  module Command
    module Routing
      module EventJudgeMethods
        private

        def judge_method_defined?(method_name)
          Pleiades::Command::Routing::EventJudgeMethods
            .private_instance_methods(false)
            .include?(judge_method(method_name))
        end

        def judge_method(event)
          :"judge_#{event}"
        end

        def judge_text(args)
          pattern =
            case args[:pattern]
            when Regexp
              args[:pattern]
            when String
              /^#{args[:pattern]}$/
            end

          pattern =~ @event.text
        end

        def judge_sticker(args)
          p_id, s_id = @event.sticker_ids
          convert_to_reg(args[:package_id]) =~ p_id &&
            convert_to_reg(args[:sticker_id]) =~ s_id
        end

        def convert_to_reg(id)
          case id
          when String, Integer
            return '*'.eql?(id) ? /^\d+$/ : /^#{id}$/
          when Array
            return /^#{id.join('|')}$/
          end
          id
        end

        def judge_postback(args)
          normalize_path(args[:scope], args[:action]) == @event.action
        end
      end
    end
  end
end
