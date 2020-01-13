require 'yaml'
require 'pleiades/core/util'

module Pleiades
  class Config
    class << self
      def configration
        @config = new(load).freeze
      end

      def method_missing(method, *_)
        return super unless @config.respond_to?(method)

        @config.__send__ method
      end

      def respond_to_missing?(_mes, *_)
        true
      end

      private

      def load
        YAML.load_file Pleiades::Constants::File::CONFIG
      end
    end

    def router_default_option
      @src.router.default.symbolize_keys
    end

    def client_keys
      @src
        .client
        .key_acquisition_process
        .each_pair.map do |_, str_proc|
          instance_eval(str_proc)
        end
    end

    private

    attr_reader :src

    def initialize(src)
      @src = Pleiades::Util.define_reader src
    end

    def method_missing(method, *_)
      @src.respond_to?(method) || super

      @src.__send__ method
    end

    def respond_to_missing?(method, *_)
      @src.respond_to?(method)
    end
  end
end
