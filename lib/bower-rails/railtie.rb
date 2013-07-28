require 'bower-rails'
require 'bower-rails/dsl'
require 'rails'

module BowerRails
  class Railtie < Rails::Railtie
    railtie_name :bower

    BowerRails::Dsl.config = {:root_path => Rails.root}
    dsl = BowerRails::Dsl.evalute(File.join("Jsfile"))

    config.after_initialize do |app|
      dsl.final_assets_path.map do |assets_root, assets_path|
        app.config.assets.paths << Rails.root.join(assets_root, assets_path, "bower_components")
      end
    end

    rake_tasks do
      load "tasks/bower.rake"
    end
  end
end
