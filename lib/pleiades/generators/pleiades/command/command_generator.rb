require 'pleiades/core/constants'
require 'pleiades/core/config'

class Pleiades::CommandGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :names, type: :array, desc: 'Specify command class name.'

  dir_options =
    {
      aliases: '-d',
      desc: 'Specify the directory to generate commands.'
    }
  class_option :dir, dir_options

  event_type_options =
    {
      aliases: '-t',
      desc: 'Specify command type.',
      default: :text,
      enum: Pleiades::Constants::Events::TYPES
    }
  class_option :event_type, event_type_options

  def setup
    @names.unshift @name
  end

  def generate_command
    commands_path = Pleiades::Config.command.commands_path
    @names.each do |name|
      template 'command.erb', "#{commands_path}/#{options['dir']}/#{name}.rb"
    end
  end

  def drow_route
    @names.each do |name|
      arg =
        [
          Pleiades::Constants::File::ROUTER,
          event_with_option(name),
          { after: /^Pleiades::Command::Router.route do/ }
        ]
      inject_into_file(*arg)
    end
  end

  private

  def event_with_option(name)
    option = event_specific_options

    str =  "\n  #{options['event_type']}"
    str += " action: '#{name}'"
    str += ", scope: '#{options['dir']}'" if options['dir']
    str += ", #{option}" if option

    str
  end

  def event_specific_options
    EventOption.const_get options['event_type'].capitalize
  rescue NameError => _e
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
