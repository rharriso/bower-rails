require 'json'
require 'pp'

namespace :bower do
  
  desc "install files from bower"
  task :install do
    #load in bower json file
    txt  = File.read("#{Rails.root}/bower.json")
    json = JSON.parse(txt)

    #install to corresponding directories
    install_components "lib", json["lib"]
    install_components "vendor", json["vendor"]
  end
end

def install_components dir, data = nil
  Dir.chdir("#{Rails.root}/#{dir}/assets/javascripts") do
    #remove old components
    FileUtils.rm_rf("components")
    #create component json
    File.open("component.json","w") do |f|
      f.write(data.to_json)
    end

    #install
    %x[bower install]
    #remove component file
    FileUtils.rm("component.json")
  end if data
end
