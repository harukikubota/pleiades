module Pleiades
  module Constants
    module Events
      TYPES = %w[
                  text
                  sticker
                  postback
                  follow
                  unfollow
      ].map(&:freeze).freeze
    end

    module File
      CONFIG_DIR_PATH = 'config/pleiades'.freeze
      CONFIG          = "#{CONFIG_DIR_PATH}/config.yml".freeze
      ROUTER          = "#{CONFIG_DIR_PATH}/router.rb".freeze
    end
  end
end
