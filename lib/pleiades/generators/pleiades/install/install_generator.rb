class Pleiades::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def generate_file
    cst = Pleiades::Constants::File
    file_paths =
      %W[
        #{cst::CONFIG}
        #{cst::INITIALIZER}
        #{cst::ROUTER}
      ]

    file_paths.each { |f| copy_file File.basename(f), f }
  end
end
