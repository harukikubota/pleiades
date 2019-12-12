require 'pleiades/core/constants'
require 'pleiades/core/config'

module Pleiades
  module Generators
    class CommandGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :name, type: :string, desc: 'Specify command class name.'

      dir_options = {
                      aliases: '-d',
                      desc: 'Specify the directory to generate commands.',
                      default: 'common'
                    }
      class_option :dir, dir_options

      event_type_options = {
                              aliases: '-t',
                              desc: 'Specify command type.',
                              default: :text,
                              enum: Pleiades::Constants::Events::TYPES
                            }
      class_option :event_type, event_type_options

      def generate_command
        commands_path = Pleiades::Config.commands_path
        template 'command.erb', "#{commands_path}/#{options['dir']}/#{name}.rb"
      end

      def drow_route
        arg = [
                Pleiades::Constants::File::ROUTER,
                event_with_option,
                { after: /^Pleiades::Command::Router.route do/ }
              ]
        inject_into_file(*arg)
      end

      private

      def event_with_option
        option = event_specific_options

        str =  "\n\t#{options['event_type']}"
        str += " scope: '#{options['dir']}', action: '#{name}'"
        str += ", #{option}" if option

        str
      end

      def event_specific_options
        EventOption.const_get options['event_type'].capitalize
      rescue NameError => _
        nil
      end

      def dirs
        options['dir'].split('/')
      end

      module EventOption
        Text    = 'pattern: //'.freeze
        Sticker = 'package_id: 1, sticker_id: 1'.freeze
      end
    end
  end
end
