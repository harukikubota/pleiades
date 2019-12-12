module Pleiades
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def generate_file
        file_paths =  %W(
                        #{Pleiades::Constants::File::CONFIG}
                        #{Pleiades::Constants::File::ROUTER}
                      )

        file_paths.each { |f| copy_file File.basename(f), f }
      end
    end
  end
end
