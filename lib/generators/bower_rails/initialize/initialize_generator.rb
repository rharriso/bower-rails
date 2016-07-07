module BowerRails
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      INITIALIZE_FILE_PATH = 'config/initializers/bower_rails.rb'

      desc 'Adds a boilerplate bower.json or Bowerfile to the root of Rails project and an empty initializer'
      source_root File.expand_path('../templates', __FILE__)
      argument :config_file, :type => :string, :default => 'bowerfile'

      def create_config_file
        config_file_name = config_file.underscore
        case config_file_name
        when 'bowerfile' then copy_file 'Bowerfile',  'Bowerfile'
        when 'json'      then copy_file 'bower.json', 'bower.json'
        else
          raise ArgumentError, 'You can setup bower-rails only using bower.json or Bowerfile. Please provide `json` or `bowerfile` as an argument instead'
        end
      end

      def copy_initializer_file
        copy_file 'bower_rails.rb', INITIALIZE_FILE_PATH
      end

      def require_initializer_in_application_rb
        if Rails.version < "4.0.0"
          environment { "require Rails.root.join(\"#{INITIALIZE_FILE_PATH}\").to_s" }
        end
      end
    end
  end
end
