require 'json'
require 'pp'

namespace :bower do
  desc "Install components from bower"
  task :install do
    perform do
      sh 'bower install'
    end
  end

  namespace :install do
    desc "Install components with -F option"
    task :force do
      perform do
        sh 'bower install -F'
      end
    end
  end

  desc "Update bower components"
  task :update do
    perform do
      sh 'bower update'
    end
  end

  desc "List bower components"
  task :list do
    perform false do
      sh 'bower list'
    end
  end

  namespace :update do
    desc "Update existing components and uninstalls extraneous components"
    task :prune do
      perform do
        sh 'bower update && bower prune'
      end
    end
  end

  namespace :list do
    desc "List bower components with paths"
    task :paths do
      perform do
        sh 'bower list --paths'
      end
    end
  end
end

def perform remove_components = true, &block
  entries = Dir.entries(get_bower_root_path)

  if entries.include?('Bowerfile')
    dsl_perform_command remove_components, &block
  elsif entries.include?('bower.json')
    perform_command remove_components, &block
  else
    raise LoadError, "No Bowerfile or bower.json file found. Make sure you have it at the root of your project"
  end
end

def get_bower_root_path
  Dir.pwd
end

def dsl_perform_command remove_components = true, &block
  dsl = BowerRails::Dsl.evalute("Bowerfile")

  if remove_components
    dsl.write_bower_json
    dsl.write_dotbowerrc
    puts "bower.js files generated"
  end

  if block_given?
    dsl.directories.each do |dir|
      Dir.chdir(dir) do
        yield
      end
    end
  end
end

#run the passed bower block in appropriate folders
def perform_command remove_components = true, &block
  bower_root = get_bower_root_path
  #load in bower json file
  txt  = File.read(File.join(bower_root, "bower.json"))
  json = JSON.parse(txt)


  #load and merge root .bowerrc
  dot_bowerrc = JSON.parse(File.read(File.join(bower_root, '.bowerrc'))) rescue {}
  dot_bowerrc["directory"] = "bower_components"

  if json.except('lib', 'vendor').empty?
    folders = json.keys
  else
    raise "Assuming a standard bower package but cannot find the required 'name' key" unless !!json['name']
    folders = ['vendor']
  end

  folders.each do |dir|
    puts "\nInstalling dependencies into #{dir}"

    data = json[dir]

    # assume using standard bower.json if folder name is not found
    data = json if data.nil?

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
        f.write(JSON.pretty_generate(dot_bowerrc))
      end

      #run command
      yield  if block_given?

      #remove bower file
      FileUtils.rm("bower.json")

      #remove .bowerrc
      FileUtils.rm(".bowerrc")
    end if data && !data["dependencies"].empty?
  end
end
