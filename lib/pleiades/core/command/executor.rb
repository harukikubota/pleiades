module Pleiades
  module Command
    class Executor
      def initialize(command, method)
        @to = command
        @method = method
      end

      def execute
        @to.__send__ @method
        @to
      end
      alias :call execute
    end
  end
end
