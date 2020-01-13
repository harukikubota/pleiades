require 'pleiades/core/command/executor'

module Pleiades
  module Command
    class Factory
      def self.production(event, path_info)
        @factory = new(event, path_info)
        @factory.operate
      end

      def initialize(event, path_info)
        @event = event
        @path_info = path_info
      end

      def operate
        executor_class(decorate_command(command_class))
      end

      private

      def command_class
        klass_path = @path_info[:command_path] || Pleiades::Config.command.default

        command_constantize(klass_path).new(@event)
      end

      def command_constantize(path)
        path.split('/').map(&:camelize).join('::').constantize
      end

      def executor_class(command)
        @path_info[:executor].constantize.new(
          command,
          @path_info[:call_method]
        )
      end

      def decorate_command(command)
        concerns = @path_info[:concern].map(&:constantize)
        command.class_eval do
          concerns.each do |concern|
            include concern
          end
        end
        command
      end
    end
  end
end
