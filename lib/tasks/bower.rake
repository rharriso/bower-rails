require 'json'
require 'pp'
namespace :bower do

  desc "install files from bower"
  task :install do
    #install to corresponding directories
    perform_command do
      sh 'bower install'
    end
  end

  desc "update bower packages"
  task :update do
    #install to corresponding directories
    perform_command false do
      sh 'bower update'
    end
  end
  
  namespace :dsl do
    desc "install files from bower"
    task :install do
      #install to corresponding directories
      dsl_perform_command do
        sh 'bower install'
      end
    end

    desc "update bower packages"
    task :update do
      #install to corresponding directories
      dsl_perform_command false do
        sh 'bower update'
      end
    end
  end
end

def dsl_perform_command remove_components = true
  BowerRails::Dsl.config = {:root_path => Rails.root}
  dsl = BowerRails::Dsl.evalute(Rails.root.join("Jsfile"))
  
  if remove_components  
    dsl.write_components_js 
    puts "component.js files generated"
  end
  
  dsl.directories.each do |dir|
    Dir.chdir(dir) do
      yield
    end
  end
end

#run the passed bower block in appropriate folders
def perform_command remove_components = true
  #load in bower json file
  txt  = File.read("#{Rails.root}/bower.json")
  json = JSON.parse(txt)

  ["lib", "vendor"].each do |dir|

    data = json[dir]

    #check folder existence and create?
    dir = "#{Rails.root}/#{dir}/assets"
    FileUtils.mkdir_p dir unless File.directory? dir
    #go in to dir to act
    Dir.chdir(dir) do

      #remove old components
      FileUtils.rm_rf("components") if remove_components

      #create component json
      File.open("component.json","w") do |f|
        f.write(data.to_json)
      end

      #run command
      yield

      #remove component file
      FileUtils.rm("component.json")

    end if data

  end
end
