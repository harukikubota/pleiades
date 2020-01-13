require 'pleiades/core/util'
require 'freeezer'

module Line
  module Bot
    module Event
      class Base
        using Freeezer

        def initialize(src)
          @src = Pleiades::Util.define_reader src

          # moduleにする
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
          @src.deep_freeze
        end

        private

        def method_missing(method, *_)
          @src.respond_to?(method) || super
          @src.__send__ method
        end

        def respond_to_missing?(method, *_)
          @src.respond_to?(method) || super
        end
      end
    end
  end
end
