require 'spec_helper'
require 'bower-rails/performer'
require 'pry'

describe BowerRails::Performer do

  let(:performer) { BowerRails::Performer.new }

  context "remove_extra_files" do
    let(:root) { File.expand_path('../../..', __FILE__) }

    before do
      # `rm -rf ./tmp` remove temporary directory
      FileUtils.rm_rf("#{root}/tmp")

      # setup temporary directory
      FileUtils.mkdir("#{root}/tmp")
      FileUtils.cp("#{root}/spec/files/Bowerfile", "#{root}/tmp/Bowerfile")

      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components")

      # creates bower library
      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components/moment")
      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components/moment/fonts")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/fonts/font.svg")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/moment.js")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/unknown.file")
      FileUtils.mkdir("#{root}/tmp/vendor/assets/bower_components/moment/unknown_dir")

      # creates bower.json with `main` files: "./moment.js", "./fonts/*"
      File.open("#{root}/tmp/vendor/assets/bower_components/moment/bower.json", "w") do |f|
        f.write(%q({"name":"moment","main":["./moment.js", "./fonts/*"]}))
      end

      # points `root_path` to temporary directory
      allow(performer).to receive(:root_path) { "#{root}/tmp" }

      Dir.chdir("#{root}/tmp")

      performer.perform false do
        remove_extra_files
      end
    end

    it "removes bower.json" do
      expect(File).to_not exist("#{root}/tmp/vendor/assets/bower_components/moment/bower.json")
    end

    it "removes unknown.file" do
      expect(File).to_not exist("#{root}/tmp/vendor/assets/bower_components/moment/unknown.file")
    end

    it "removes unknown_dir" do
      expect(File).to_not exist("#{root}/tmp/vendor/assets/bower_components/moment/unknown_dir")
    end

    it "keeps moment.js" do
      expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/moment.js")
    end

    it "keeps font/font.svg" do
      expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/fonts/font.svg")
    end
  end

end
