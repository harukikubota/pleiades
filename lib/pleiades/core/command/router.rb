require 'pleiades/core/constants'
require 'pleiades/core/config'
require 'pleiades/core/command/nest_blocks'
require 'pleiades/core/command/event_proccessor'

module Pleiades
  module Command
    class Router
      prepend Pleiades::Command::NestBlocks
      prepend Pleiades::Command::EventProccessor

      class << self
        attr_accessor :path
        attr_reader :event

        def find_route(event)
          @event = event
          @path = nil

          load Pleiades::Constants::File::ROUTER

          Router.path_found? ? Router.path : 'base_command'
        end

        def route(&block)
          new.instance_eval(&block) if block_given?
        end

        def path_found?
          @path ? true : false
        end
      end

      def initialize(options = nil)
        @event = Router.event
        @options = options || default_options
      end

      private

      def normalize_path(scope = nil, action = nil)
        dirs = []

        dirs << @options[:scope] if @options[:scope].any?
        dirs << scope if scope
        dirs << (action || @options[:action])

        dirs.join('/')
      end

      def talk_type(*callable_types, &block)
        instance_eval(&block) if callable_type?(callable_types)
      end

      def callable_type?(types)
        types.map(&:to_s).include?(@event.source.type)
      end
    end
  end
end
