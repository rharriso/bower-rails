require 'json'
require 'pp'

namespace :bower do
  
  desc "install files from bower"
  task :install do    
    #install to corresponding directories
    perform_command do 
      %x[bower install]
    end
  end

  desc "update bower packages"
  task :update do    
    #install to corresponding directories
    perform_command false do
      %x[bower update]
    end
  end
end

#run the passed bower block in appropriate folders
def perform_command remove_components = true, &block
  #load in bower json file
  txt  = File.read("#{Rails.root}/bower.json")
  json = JSON.parse(txt)

  ["lib", "vendor"].each do |dir|

    data = json[dir]

    #go in to dir to act
    Dir.chdir("#{Rails.root}/#{dir}/assets/javascripts") do
      
      #remove old components
      FileUtils.rm_rf("components") if remove_components
      
      #create component json
      File.open("component.json","w") do |f|
        f.write(data.to_json)
      end

      #run command
      block.call

      #remove component file
      FileUtils.rm("component.json")

    end if data

  end
end
