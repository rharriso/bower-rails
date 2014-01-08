require 'spec_helper'

describe BowerRails do
  it 'should set default value for resolve_before_precompile option' do
    expect(BowerRails.resolve_before_precompile).to eq(false)
  end

  it 'should set resolve_before_precompile option' do
    BowerRails.configure do |bower_rails|
      bower_rails.resolve_before_precompile = true
    end

    expect(BowerRails.resolve_before_precompile).to eq(true)
  end
end