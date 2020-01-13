module Pleiades
  class Railtie < ::Rails::Railtie
    generators do
      Dir
        .glob("#{File.expand_path('generators/pleiades', __dir__)}/*")
        .map  { |f| "#{f}/#{File.basename(f)}_generator.rb" }
        .each { |f| require_relative f }
    end
  end
end
