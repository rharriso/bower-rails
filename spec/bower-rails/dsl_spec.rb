require 'spec_helper'

describe BowerRails::Dsl do
  subject { BowerRails::Dsl.new(Dir.pwd) }

  it "should have a default group of :vendor with the default assets_path" do
    subject.send(:groups).should == [[:vendor, {:assets_path => "assets"}]]
  end

  it "should properly set the assets_path when a default is passed after initialization" do
    subject.send :assets_path, 'assets/javascripts'
    subject.send(:groups).should == [[:vendor, {:assets_path => 'assets/javascripts'}]]
  end

  context "dependency group dsl method" do

    it "should fallback to default group when no block" do
      subject.send(:current_dependency_group).should eq :dependencies
    end


    it "should create a group with just a name" do
      subject.send :dependency_group, :dev_dependencies do
        subject.send(:current_dependency_group).should eq :dev_dependencies
      end
    end

    it "should return parent group after the block" do
      subject.send :dependency_group, :dev_dependencies do
        subject.send(:current_dependency_group).should eq :dev_dependencies
      end
      subject.send(:current_dependency_group).should eq :dependencies
    end

    it "should normalize the name to camelCase " do
      subject.send :dependency_group, :dev_dependencies do
        subject.send(:current_dependency_group_normalized).should eq :devDependencies
      end
      subject.send(:current_dependency_group_normalized).should eq :dependencies
    end

  end

  context "group dsl method" do
    it "should create a group with just a name" do
      subject.send :group, :vendor
      subject.send(:groups).should include [:vendor, {:assets_path => "assets"}]
    end

    it "should assign a group custom assets_path if not provided" do
      subject.send :assets_path, "assets/somepath"
      subject.send :group, :vendor
      subject.send(:groups).should include [:vendor, {:assets_path => "assets/somepath"}]
    end

    it "should ensure that group has a correct name" do
      lambda {subject.send :group, :foo }.should raise_error(ArgumentError)
    end

    it "should ensure that :assets_path option begins with '/assets'" do
      subject.send :group, :vendor, { :assets_path => "/assets/bar"}
      lambda { subject.send(:group, :vendor, { :assets_path => "/not-assets/bar"}) }.should raise_error(ArgumentError)
      subject.send(:groups).should include [:vendor, { :assets_path => "/assets/bar"}]
    end
  end

  context "asset dsl method" do
    it "should default to the latest version" do
      subject.asset :new_hotness
      subject.dependencies.values.should include :dependencies => {:new_hotness => "latest"}
    end

    it "should accept a version string" do
      subject.asset :new_hotness, "1.0"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "1.0"}
    end

    it "should accept a git url" do
      subject.asset :new_hotness, "git@github.com:initech/tps-kit"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git@github.com:initech/tps-kit"}
    end

    it "should accept git url and a version and put it all together" do
      subject.asset :new_hotness, "1.2.3", :git => "git@github.com:initech/tps-kit"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git@github.com:initech/tps-kit#1.2.3"}
    end

    it "should accept a github path" do
      subject.asset :new_hotness, :github => "initech/tps-kit"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git://github.com/initech/tps-kit"}
    end

    it "should accept a github path and a version and put it all together" do
      subject.asset :new_hotness, "1.2.3", :github => "initech/tps-kit"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git://github.com/initech/tps-kit#1.2.3"}
    end

    it "should accept a ref option and set it as a version" do
      subject.asset :new_hotness, :ref => "b122a"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "b122a"}
    end

    it "should accept a git and ref option and put it all together" do
      subject.asset :new_hotness, :git => "git@github.com:initech/tps-kit", :ref => "b122a"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git@github.com:initech/tps-kit#b122a"}
    end

    it "should accept a github and ref option and put it all together" do
      subject.asset :new_hotness, :github => "initech/tps-kit", :ref => "b122a"
      subject.dependencies.values.should include :dependencies => {:new_hotness => "git://github.com/initech/tps-kit#b122a"}
    end

    it "should accept a main_files option and put it all together" do
      subject.asset :new_hotness, :main_files => ['dist/foo.js']
      subject.main_files.should eq(new_hotness: ['dist/foo.js'])
    end

    it "should be able to set main_files via block and put it all together" do
      subject.asset :new_hotness do
        main_files ['dist/foo.js']
      end
      subject.main_files.should eq(new_hotness: ['dist/foo.js'])
    end

  end

  it "should have a private method to validate asset paths" do
    subject.send(:assert_asset_path, "/assets/bar")
    lambda { subject.send(:assert_asset_path, "/not-assets/bar") }.should raise_error(ArgumentError)
  end

  it "should have a private method to validate group name" do
    subject.send(:assert_group_name, :vendor)
    lambda { subject.send(:assert_group_name, :invalid) }.should raise_error(ArgumentError)
  end

  context "default_group dsl method" do
    it "should set the default group" do
      subject.send(:default_group).should eq [:vendor, { :assets_path => "assets" }]
    end

    it "should set the default group with custom assets_path" do
      subject.send :assets_path, "assets/somepath"
      subject.send(:default_group).should eq [:vendor, { :assets_path => "assets/somepath" }]
    end
  end

  describe '.evalute' do
    let(:tmp_bowerfile) { 'asset "moment"' }
    before do
      allow(File).to receive(:open).with('tmp/Bowerfile', 'rb').and_return(tmp_bowerfile)
    end

    context 'when use_gem_deps_for_bowerfile is true' do
      let(:gem1) { double(Gem::Specification, gem_dir: 'gem1') }
      let(:gem1_bowerfile) { 'asset "jquery"' }
      let(:gem2) { double(Gem::Specification, gem_dir: 'gem2') }

      before do
        BowerRails.use_gem_deps_for_bowerfile = true
        allow(Gem::Specification).to receive(:map).and_yield(gem1).and_yield(gem2)
        allow(File).to receive(:exist?).with('gem1/Bowerfile').and_return(true)
        allow(File).to receive(:exist?).with('gem2/Bowerfile').and_return(false)
        allow(File).to receive(:open).with('gem1/Bowerfile', 'rb').and_return(gem1_bowerfile)
      end

      it 'should also evaluate Bowerfile in dependency' do
        dsl = BowerRails::Dsl.evalute('tmp', 'Bowerfile')
        dependencies = dsl.dependencies['tmp/vendor/assets'][:dependencies]
        expect(dependencies.count).to eq(2)
        expect(dependencies).to have_key('jquery')
        expect(dependencies).to have_key('moment')
      end
    end

    context 'when use_gem_deps_for_bowerfile is false' do
      it 'should evaluate Bowerfile in project' do
        dsl = BowerRails::Dsl.evalute('tmp', 'Bowerfile')
        dependencies = dsl.dependencies['tmp/vendor/assets'][:dependencies]
        expect(dependencies.count).to eq(1)
        expect(dependencies).to have_key('moment')
      end
    end
  end
end
