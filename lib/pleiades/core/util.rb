# frozen_string_literal: true

module Pleiades

  # Util Modules.
  module Util
    class << self
      def define_reader(hash)
        Struct.new(
          *hash.keys.map { |key| key.underscore.to_sym }
        ).new(
          *hash.values.map { |s| Hash === s ? define_reader(s) : s.freeze }
                      .map(&:freeze)
        )
      end
    end
  end
end
