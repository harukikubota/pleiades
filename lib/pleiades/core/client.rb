require 'pleiades/core/client/wrapper'

module Pleiades
  module Client
    def self.included(base)
      include_modules = [Common]

      on_controller_class = ApplicationController.subclasses.include?(base)

      include_modules << Controller if on_controller_class

      include_modules.each do |mod|
        base.include mod
      end
    end

    module Common
      def self.included(base)
        base.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def client
            return @client if @client

            channel_secret, channel_token = Pleiades::Config.client_keys

            @client = Line::Bot::Client.new do |config|
              config.channel_secret = channel_secret
              config.channel_token = channel_token
            end
          end
        RUBY
      end
    end

    module Controller
      def validate_signature
        client.validate_signature(body, signature)
      end

      def signature
        request.env['HTTP_X_LINE_SIGNATURE']
      end

      def body
        @body ||= request.body.read
      end

      def events
        client.parse_events_from(body)
      end
    end
  end
end
