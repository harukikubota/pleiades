module Pleiades
  module Command
    class BaseCommand
      def initialize(event)
        @event = event
      end

      def call; end
    end
  end
end
