require 'pleiades/core/command/base_command'
require 'pleiades/core/command/executor'
require 'pleiades/core/command/factory'
require 'pleiades/core/command/router'
require 'pleiades/core/command/routing_proxy'
require 'pleiades/core/config'

module Pleiades
  module Command
    class << self
      def get(event)
        event = Pleiades::Util.define_reader(event).freeze

        RoutingProxy.collect_router_file(event).each do |path|
          Router.find_route(event, path)
          break if Router.path_found?
        end

        Factory.production(event, Router.path_info)
      end
    end
  end
end
