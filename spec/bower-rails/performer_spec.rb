require 'spec_helper'
require 'bower-rails/performer'
require 'pry'

describe BowerRails::Performer do
  let(:performer) { BowerRails::Performer.new }
  let(:main_files) { {} }
  let(:exempt_list) { nil }
  let(:root) { File.expand_path('../../..', __FILE__) }
  let(:tmp_dir) { File.join root, "tmp" }
  let(:files_dir) { File.join root, "spec", "files" }
  let(:create_bower_file) { true }

  before do
    # `rm -rf ./tmp` remove temporary directory
    FileUtils.rm_rf("#{root}/tmp")

    # setup temporary directory
    FileUtils.mkdir("#{root}/tmp")
    FileUtils.cp("#{root}/spec/files/Bowerfile", "#{root}/tmp/Bowerfile") if create_bower_file
    FileUtils.cp("#{root}/spec/files/bower.json", "#{root}/tmp/bower.json")

    # points `root_path` to temporary directory
    allow(performer).to receive(:root_path) { "#{root}/tmp" }

    # trick BowerRails that system has bower installed
    allow(performer).to receive(:find_command) { "bower" }

    # sets main_files in DSL
    allow_any_instance_of(BowerRails::Dsl).to receive(:main_files){ main_files }

    Dir.chdir("#{root}/tmp")

    # Stub exclude from clean setting
    BowerRails.exclude_from_clean = exempt_list
  end

  describe "remove_extra_files" do
    before do
      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components")

      # creates bower library
      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components/moment")
      FileUtils.mkdir_p("#{root}/tmp/vendor/assets/bower_components/moment/fonts")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/fonts/font.svg")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/moment.js")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/unknown.file")
      FileUtils.touch("#{root}/tmp/vendor/assets/bower_components/moment/moment_plugin.js")
      FileUtils.mkdir("#{root}/tmp/vendor/assets/bower_components/moment/unknown_dir")

      # creates bower.json with `main` files: "./moment.js", "./fonts/*"
      File.open("#{root}/tmp/vendor/assets/bower_components/moment/bower.json", "w") do |f|
        f.write(%q({"name":"moment","main":["./moment.js", "./fonts/*"]}))
      end

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

    it "removes moment_plugin.js" do
      expect(File).to_not exist("#{root}/tmp/vendor/assets/bower_components/moment/moment_plugin.js")
    end

    context "with additional main_files" do
      let(:main_files) { { 'moment' => ['./moment_plugin.js'] } }

      it "keeps moment_plugin.js" do
        expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/moment_plugin.js")
      end
    end

    context 'with moment exempt from clean' do
      let(:exempt_list) { ['moment'] }

      it 'keeps bower.json' do
        expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/bower.json")
      end

      it 'keeps unknown.file' do
        expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/unknown.file")
      end

      it 'keeps unknown_dir' do
        expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/unknown_dir")
      end

      it 'keeps moment_plugin.js' do
        expect(File).to exist("#{root}/tmp/vendor/assets/bower_components/moment/moment_plugin.js")
      end
    end

    context 'without Bowerfile but with bower.json' do
      let(:create_bower_file) { false }

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

      it "removes moment_plugin.js" do
        expect(File).to_not exist("#{root}/tmp/vendor/assets/bower_components/moment/moment_plugin.js")
      end
    end
  end

  describe "resolve_asset_paths" do
    let(:target_path) { "#{tmp_dir}/vendor/assets/bower_components/foobar/style.css" }

    before do
      FileUtils.mkdir_p(File.dirname(target_path))
      FileUtils.cp("#{files_dir}/style.css", target_path)

      performer.perform false do
        resolve_asset_paths
      end
    end

    it "removes .css file" do
      expect(File).to_not exist(target_path)
    end

    it "creates .css.erb file" do
      expect(File).to exist("#{target_path}.erb")
    end

    describe "created .erb file" do
      subject { File.read "#{target_path}.erb" }

      it "includes proper asset paths" do
        expect(subject).to include "<%= asset_path 'foobar.png' %>"
      end

      it "does not include improper asset paths" do
        expect(subject).not_to match(/<%= asset_path 'foobar.png[?#]/)
      end

      it "pushes url params after the erb block" do
        expect(subject).to include "<%= asset_path 'foobar.png' %>?"
      end

      it "pushes url anchor after the erb block" do
        expect(subject).to include "<%= asset_path 'foobar.png' %>#"
      end
    end
  end
end
