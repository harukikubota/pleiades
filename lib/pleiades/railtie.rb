module Pleiades
  class Railtie < ::Rails::Railtie
    generators do

      generator_names = %w(
                            install
                            setup
                            command
                          )

      generator_path = './generators/pleiades'.freeze
      generator_names
        .map  { |f| "#{generator_path}/#{f}/#{f}_generator.rb" }
        .each { |f| require_relative f }

    end
  end
end
