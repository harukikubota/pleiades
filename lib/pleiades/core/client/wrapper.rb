module Pleiades
  module Client
    class Wrapper
      attr_reader :histories

      def initialize(client)
        @obj = client
        @histories = []
      end

      private

      def method_missing(method, *args, &block)
        return super unless @obj.respond_to?(method)

        execute(method, *args)
      end

      def respond_to_missing?(method, *_, &_)
        @obj.respond_to?(method) || super
      end

      def respond_to?(method)
        @obj.respond_to?(method) || super
      end

      def execute(method, *args)
        res = @obj.__send__ method, *args
        code = res.code
        body = JSON.parse(res.body)

        @histories << response.new(method, code, body)

        [code, body]
      end

      def method_assigns(method, *args)
        return {} if args.empty?

        @obj.method(method)
            .parameters
            .map(&:last)
            .each_with_index
            .each_with_object({}) do |(arg_name, at), hash|
              hash.store(arg_name, args[at])
            end
      end

      def response
        attributes = %i[method_name code body]
        Struct.new(*attributes)
      end
    end
  end
end
