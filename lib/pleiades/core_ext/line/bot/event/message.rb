module Line
  module Bot
    module Event
      class Message

        # ユーザの送信メッセージ
        #
        # @return EXAMPLE 'Hello world.'
        #
        def text
          message.text
        end

        # ユーザの送信スタンプのids(パッケージID、スタンプID)
        #
        # @return EXAMPLE ["1", "1"]
        #
        def sticker_ids
          [message.package_id, message.sticker_id]
        end
      end
    end
  end
end
