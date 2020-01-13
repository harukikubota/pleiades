module Pleiades
  module Command
    module Routing
      class Result
        include Pleiades::Command::Routing::PathBuilder

        def self.create(options, event_args = {})
          new(options, event_args).send :create
        end

        private

        def initialize(options, event_args)
          @options = options
          @event_args = event_args
        end

        def create
          attributes.each_with_object({}) do |method_name, result|
            result.store(method_name, send(method_name))
          end
        end

        def attributes
          rejects = %i[initialize create] << __method__
          private_methods(false).without(*rejects)
        end

        def command_path
          normalize_path(@event_args[:scope], @event_args[:action])
        end

        def call_method
          @options[:method]
        end

        def concern
          @options[:concern]
        end

        def executor
          @options[:executor]
        end
      end
    end
  end
end
