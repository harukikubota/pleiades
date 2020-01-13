module Pleiades
  module Command
    module Routing
      module Reflection
        extend ActiveSupport::Concern

        def __event_name__
          @event.type
        end
      end
    end
  end
end
