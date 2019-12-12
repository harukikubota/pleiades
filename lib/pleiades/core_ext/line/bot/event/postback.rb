module Line
  module Bot
    module Event
      class Postback
        attr_reader :action, :params

        def initialize src
          super
          set_instance_variables
        end

        private

        # dataプロパティからインスタンス変数に設定する。
        #
        # action 'path/to/command'
        # params '{product_id: 1, order_num: 3}'
        def set_instance_variables
          data = postback.data.split('&')
                              .map { |s| s.split('=') }
                              .each_with_object({}) { |(key, val), hash| hash[key.to_sym] = val }

          @action = data.delete :action
          @params = data
        end
      end
    end
  end
end
