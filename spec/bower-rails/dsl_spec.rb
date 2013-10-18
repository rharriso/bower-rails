require 'spec_helper'

describe BowerRails::Dsl do
  subject { BowerRails::Dsl.new }

  it "should have a default group of :vendor with the default assets_path" do
    subject.send(:groups).should == [[:vendor, {:assets_path => "assets"}]]
  end

  it "should properly set the assets_path when a default is passed after initialization" do
    subject.send(:assets_path, 'assets/javascripts')
    subject.send(:groups).should == [[:vendor, {:assets_path => 'assets/javascripts'}]]
  end
end
