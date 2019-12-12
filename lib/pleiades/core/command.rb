require 'pleiades/core/command/router'
require 'pleiades/core/command/base_command'
require 'pleiades/core/config'

module Pleiades
  module Command
    class << self
      def get event
        path = Pleiades::Command::Router.find_route event

        command_cst = path.split('/')
                          .map(&:camelize)
                          .join('::')

        command_cst.constantize.new(event)
      end
    end
  end
end
