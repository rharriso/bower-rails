module BowerRails
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      desc "Adds a boilerplate component.json file to root of rails project"

      def self.source_root
        @_bower_rails_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_initializer_file
        template "bower.json", 'bower.json'
      end

    end
  end
end