require 'yaml'
require 'pleiades/core/util'

module Pleiades
  class Config
    class << self
      def configration
        return nil if loaded?

        @config = new(load).freeze
        @loaded = true
      end

      def loaded?
        @loaded
      end

      def method_missing method, *_
        configration
        return super unless instance_methods.include?(method)

        @config.__send__ method
      end

      def respond_to_missing? method, _
        instance_methods.include?(method)
      end

      private

      def load
        YAML.load_file Pleiades::Constants::File::CONFIG
      end
    end

    def commands_path
      @src.command.commands_path
    end

    def disp_console
      @src.debug.disp_console
    end

    private

    attr_reader :src

    def initialize src
      @src = Pleiades::Util.define_reader src
    end
  end
end
