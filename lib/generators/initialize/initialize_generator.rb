module BowerRails
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      desc "Adds a boilerplate component.json file to root of rails project"
    end

    def self.source_root
      @_bower_rails_source_root ||= File.expand_path("templates", __FILE__)
    end

    def create_component_file
      template "component.json", 'component.json'
    end
  end
end