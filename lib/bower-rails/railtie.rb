require 'bower-rails'
require 'rails'
module BowerRails
  class Railtie < Rails::Railtie
    railtie_name :bower

    config.after_initialize do |app|
      ["lib", "vendor"].each do |dir|
        app.config.assets.paths << Rails.root.join(dir, 'assets', 'bower_components')
      end
    end

    rake_tasks do
      load "tasks/bower.rake"
    end
  end
end
