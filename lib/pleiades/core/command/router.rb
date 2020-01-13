require 'pleiades/core/constants'
require 'pleiades/core/config'
require 'pleiades/core/command/routing/event_proccessor'
require 'pleiades/core/command/routing/nest_blocks'
require 'pleiades/core/command/routing/path_builder'
require 'pleiades/core/command/routing/reflection'
require 'pleiades/core/command/routing/result'
require 'pleiades/core/command/routing/validator'

module Pleiades
  module Command
    class Router
      prepend Pleiades::Command::Routing::EventProccessor
      prepend Pleiades::Command::Routing::NestBlocks
      prepend Pleiades::Command::Routing::PathBuilder
      prepend Pleiades::Command::Routing::Reflection
      prepend Pleiades::Command::Routing::Validator

      class << self
        attr_reader :event
        attr_writer :path_info

        def find_route(event, router_path)
          @event = event
          @path_info = nil

          load router_path
        end

        def route(&block)
          new.instance_eval(&block) if block_given?
        end

        def path_info
          @path_info || default_path_info
        end

        def default_path_info
          new.instance_eval { Pleiades::Command::Routing::Result.create(@options) }
        end

        def path_found?
          !!@path_info
        end
      end

      attr_reader :options

      def initialize(options = nil)
        @event = Router.event
        @options = options || default_options
      end

      private

      def nest(new_option, &block)
        self.class.new(new_option).instance_eval(&block)
      end
    end
  end
end
