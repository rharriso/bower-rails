require 'bower-rails'
require 'rails'
module BowerRails
  class Railtie < Rails::Railtie
    railtie_name :bower

    ["lib", "vendor"].each do |dir|
      config.assets.paths << Rails.root.join(dir, 'assets', 'components')
    end

    rake_tasks do
      load "tasks/bower.rake"
    end
  end
end