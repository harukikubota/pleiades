module Pleiades
  module Command
    module Routing
      module PathBuilder
        extend ActiveSupport::Concern
        def normalize_path(scope = nil, action = nil)
          dirs = []

          dirs << @options[:scope] if @options[:scope].any?
          dirs << scope if scope
          dirs << (action || @options[:action])

          dirs.join('/')
        end
      end
    end
  end
end
