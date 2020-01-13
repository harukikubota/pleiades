require 'pleiades'

class Line::ApiController < ApplicationController
  include Pleiades::Client

  def callback
    validate_signature || head(:bad_request)

    events.each do |event|
      Pleiades::Command.get(event).call
    end
    head :ok
  end
end
