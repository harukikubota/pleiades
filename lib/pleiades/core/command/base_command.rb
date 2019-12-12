module Pleiades
  module Command
    class BaseCommand
      def initialize event
        @event = event
        @success = nil
      end

      def call; end

      def success?
        @success
      end

      protected

      def success!
        @success = true
      end

      def fail!
        @success = false
      end
    end
  end
end
