require 'bower-rails/performer'

namespace :bower do
  desc "Install components from bower"
  task :install, :options do |_, args|
    if ENV['RAILS_ENV'] && ENV['RAILS_ENV'] == 'development'
      Rake::Task["bower:install:development"].invoke(args[:options])
    else
      Rake::Task["bower:install:production"].invoke(args[:options])
    end
  end

  namespace :install do
    desc "Install components from bower using previously generated bower.json"
    task :deployment, :options do |_, args|
      args.with_defaults(:options => '')
      BowerRails::Performer.perform false do |bower|
        sh "#{bower} install #{args[:options]}"
      end
    end

    desc "Install both dependencies and devDependencies from bower"
    task :development, :options do |_, args|
      args.with_defaults(:options => '')
      BowerRails::Performer.perform do |bower|
        sh "#{bower} install #{args[:options]}"
      end
    end

    desc "Install only dependencies, excluding devDependencies from bower"
    task :production, :options do |_, args|
      args.with_defaults(:options => '')
      BowerRails::Performer.perform do |bower|
        sh "#{bower} install -p #{args[:options]}"
      end
    end
  end

  desc "Update bower components"
  task :update, :options do |_, args|
    args.with_defaults(:options => '')
    BowerRails::Performer.perform do |bower|
      sh "#{bower} update #{args[:options]}"
    end
  end

  desc "List bower components"
  task :list do
    BowerRails::Performer.perform false do |bower|
      sh "#{bower} list"
    end
  end

  namespace :update do
    desc "Update existing components and uninstalls extraneous components"
    task :prune, :options do |_, args|
      args.with_defaults(:options => '')
      BowerRails::Performer.perform do |bower|
        sh "#{bower} update #{args[:options]} && #{bower} prune #{args[:options]}"
      end
    end
  end

  desc "Resolve assets paths in bower components"
  task :resolve do
    BowerRails::Performer.perform false do
      resolve_asset_paths
    end
  end

  desc "Attempt to keep only files listed in 'main' of each component's bower.json"
  task :clean do
    BowerRails::Performer.perform false do
      remove_extra_files
    end
  end

  namespace :cache do
    desc "Clear the bower cache ('bower cache clean')"
    task :clean do
      BowerRails::Performer.perform false do |bower|
        sh "#{bower} cache clean"
      end
    end
  end

  task :before_precompile do
    BowerRails.tasks.each do |task|
      Rake::Task[task].invoke
    end
  end
end

task "assets:precompile" => ["bower:before_precompile"]
