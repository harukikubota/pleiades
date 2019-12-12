require 'pleiades'

class Line::ApiController < ApplicationController
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    client.validate_signature(body, signature) || head(:bad_request)

    events = client.parse_events_from(body)

    events.each do |event|
      command = Pleiades::Command.get(event)
      command.call
      head :ok if command.success?
    end
  end
end
