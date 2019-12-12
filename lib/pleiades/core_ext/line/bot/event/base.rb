require 'pleiades/core/util'

module Line
  module Bot
    module Event
      class Base
        def initialize src
          @src = Pleiades::Util.define_reader src

          # /^[a-z]+_event\?$/
          #  => トークタイプの判定メソッドに反応する。
          #
          # @src.source.type => 'user'
          #   user_event? => true
          #   room_event? => false
          #   hoge_event? => false
          #
          @src.define_singleton_method(:method_missing) do |method, *_|
            return super() unless /^[a-z]+_event\?$/ =~ method
            source.type == method.to_s.split('_').first
          end
        end

        def method_missing method, *_
          begin
            @src.__send__ method
          rescue ArgumentError => _
            raise NoMethodError, "#{self.class} has no `#{method}` method."
          end
        end
      end
    end
  end
end
