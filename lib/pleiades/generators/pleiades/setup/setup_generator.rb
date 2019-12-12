module Pleiades
  module Generators
    class SetupGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      exe_user_options =  {
                            aliases: '-u',
                            type: :boolean,
                            desc: 'Execute generate migration:user & user_related_commands'
                          }
      class_option :user_related_files, exe_user_options

      def gen_user_related_files
        return unless options['user_related_files']

        gen_user_table unless user_table_exist?
        gen_users_command unless users_command_exist?
      end

      def gen_base_command
        return if base_command_exist?

        copy_file File.basename(command_file_path), command_file_path
      end

      def gen_command_concern
        return if command_concern_exist?

        template File.basename(command_concern_path('e')), command_concern_path
      end

      def gen_controller
        return if controller_file_exist?

        generate 'controller', controller_dir

        route <<~EOF
          namespace :line do
            namespace :api do
              post '/' , action: 'callback'
            end
          end
        EOF
        File.delete controller_file_path
        copy_file File.basename(controller_file_path), controller_file_path
      end

      private

      def method_missing(method, *_)
        method_name = /^(([a-z]+_)+)exist\?$/.match(method.to_s)
        return super unless method_name

        File.exist? method(:"#{method_name[1]}path").call
      end

      # UserModelのマイグレーションファイル生成
      def gen_user_table
        generate 'model', "user #{migration_arguments}"

        user_schemas.each_pair do |key, val|
          next unless val[:options]

          inject_into_file(
            migration_file_path,
            ", #{val[:options]}",
            after: key
          )
        end
      end

      # ユーザに関するコマンドの生成
      def gen_users_command
        dir = 'users'
        command_events = %w[follow unfollow]

        command_events.each { |event| generate 'pleiades:command', "#{event} -d #{dir} -t #{event}" }
      end

      def migration_arguments
        user_schemas
          .each_pair
          .inject('') { |str, (key, val)| "#{str}#{key}:#{val[:type]} " }
      end

      def user_schemas
        {
          line_id:          { type: :string, options: 'null: false, unique: true' },
          unsubscrided:     { type: :boolean },
          unsubscrided_at:  { type: :datetime }
        }
      end

      def user_table_path
        path = Dir.glob(migration_file_path).first
        path || migration_file_path
      end

      def migration_file_path
        'db/migrate/*_users.rb'
      end

      def users_command_path
        "#{Pleiades::Config.commands_path}/users/follow.rb"
      end

      def base_command_path
        "#{Pleiades::Config.commands_path}/base_command.rb"
      end

      def command_concern_path(add_ext = false)
        ext = add_ext ? true.to_s[3] : ''
        "#{Pleiades::Config.commands_path}/concerns/command_common.#{ext}rb"
      end

      def controller_file_path
        "app/controllers/#{controller_dir}_controller.rb"
      end

      def controller_dir
        'line/api'
      end
    end
  end
end
