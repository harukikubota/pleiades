# frozen_string_literal: true

module Pleiades
  # Util Modules.
  module Util
    class << self
      def define_reader(hash)
        hash.instance_eval do
          hash.each_pair do |key, val|
            l_val = val.is_a?(Hash) ? Pleiades::Util.define_reader(val) : val
            define_singleton_method(key.to_s.underscore.to_sym) do
              l_val
            end
          end
        end
        hash
      end
    end
  end
end
