require 'json'
require 'pp'

namespace :bower do

  desc "install components from bower"
  task :install do
    #install to corresponding directories
    perform_command do
      sh 'bower install'
    end
  end

  namespace :install do
    desc "install components with -F option"
    task :force do
      perform_command do
        sh 'bower install -F'
      end
    end
  end

  desc "update bower components"
  task :update do
    #install to corresponding directories
    perform_command false do
      sh 'bower update'
    end
  end

  namespace :update do
    desc "update existing components and uninstalls extraneous components"
    task :prune do
      perform_command false do
        sh 'bower update && bower prune'
      end
    end
  end

  namespace :dsl do
    desc "install components from bower"
    task :install do
      #install to corresponding directories
      dsl_perform_command do
        sh 'bower install'
      end
    end

    namespace :install do
      desc "install components with -F option"
      task :force do
        dsl_perform_command do
          sh 'bower install -F'
        end
      end
    end

    desc "update bower components"
    task :update do
      #install to corresponding directories
      dsl_perform_command false do
        sh 'bower update'
      end
    end

    namespace :update do
      desc "update existing components and uninstalls extraneous components"
      task :prune do
        dsl_perform_command false do
          sh 'bower update && bower prune'
        end
      end
    end
    
  end

end

def get_bower_root_path
  if defined?(Rails)
    return Rails.root
  else
    return Dir.pwd
  end
end

def dsl_perform_command remove_components = true
  bower_root = get_bower_root_path
  BowerRails::Dsl.config = {:root_path => bower_root}
  dsl = BowerRails::Dsl.evalute(File.join(bower_root, "Bowerfile"))

  if remove_components
    dsl.write_bower_json
    dsl.write_dotbowerrc
    puts "bower.js files generated"
  end

  dsl.directories.each do |dir|
    Dir.chdir(dir) do
      yield
    end
  end
end

#run the passed bower block in appropriate folders
def perform_command remove_components = true
  bower_root = get_bower_root_path
  #load in bower json file
  txt  = File.read(File.join(bower_root, "bower.json"))
  json = JSON.parse(txt)

  ["lib", "vendor"].each do |dir|

    data = json[dir]

    #check folder existence and create?
    dir = File.join(bower_root, dir, "assets")
    FileUtils.mkdir_p dir unless File.directory? dir
    #go in to dir to act
    Dir.chdir(dir) do

      #remove old components
      FileUtils.rm_rf("bower_components") if remove_components

      #create bower json
      File.open("bower.json", "w") do |f|
        f.write(data.to_json)
      end

      #create .bowerrc
      File.open(".bowerrc", "w") do |f|
        f.write(JSON.pretty_generate({:directory => "bower_components"}))
      end

      #run command
      yield

      #remove bower file
      FileUtils.rm("bower.json")

      #remove .bowerrc
      FileUtils.rm(".bowerrc")
    end if data && !data["dependencies"].empty?
  end
end
