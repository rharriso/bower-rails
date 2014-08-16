require 'bower-rails'
require 'bower-rails/dsl'
require 'rails'

module BowerRails
  class Railtie < Rails::Railtie
    railtie_name :bower
    @@bowerfile = File.join("Bowerfile")

    if File.exist?(@@bowerfile)
      config.before_initialize do |app|
        @dsl = BowerRails::Dsl.evalute(BowerRails.root_path, @@bowerfile)
        @dsl.final_assets_path.map do |assets_root, assets_path|
          app.config.assets.paths << Rails.root.join(assets_root, assets_path, "bower_components")
        end
      end
    else
      config.before_initialize do |app|
        ["lib", "vendor"].each do |dir|
          app.config.assets.paths << Rails.root.join(dir, 'assets', 'bower_components')
        end
      end
    end

    rake_tasks do
      load "tasks/bower.rake"
    end
  end
end
