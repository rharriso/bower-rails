require 'spec_helper'

describe BowerRails::Dsl do
  subject { BowerRails::Dsl.new }

  it "should have a default group of :vendor with the default assets_path" do
    subject.send(:groups).should == [[:vendor, {:assets_path => "assets"}]]
  end

  it "should properly set the assets_path when a default is passed after initialization" do
    subject.send :assets_path, 'assets/javascripts'
    subject.send(:groups).should == [[:vendor, {:assets_path => 'assets/javascripts'}]]
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
      subject.dependencies.values.should include :new_hotness => "latest"
    end

    it "should accept a version string" do
      subject.asset :new_hotness, "1.0"
      subject.dependencies.values.should include :new_hotness => "1.0"
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
end
