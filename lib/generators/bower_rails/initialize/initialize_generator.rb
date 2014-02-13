module BowerRails
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      desc "Adds a boilerplate bower.json or Bowerfile  to root of rails project"

      argument :layout, :type => :string, :default => "bowerfile"
      def self.source_root
        @_bower_rails_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_initializer_file
        type = layout.underscore
        if type == "json"
          template "bower.json", 'bower.json'
        elsif type == "bowerfile"
          copy_file 'Bowerfile', 'Bowerfile'
        end
      end
    end
  end
end