require 'spec_helper'

describe BowerRails do
  it 'should set default value for resolve_before_precompile option' do
    expect(BowerRails.resolve_before_precompile).to eq(false)
  end

  it 'should set default value for clean_before_precompile option' do
    expect(BowerRails.clean_before_precompile).to eq(false)
  end

  describe '#configure' do
    before :each do
      BowerRails.configure do |bower_rails|
        bower_rails.resolve_before_precompile = false
        bower_rails.resolve_before_precompile = false
      end
    end

    describe '#resolve_before_precompile' do
      before do
        BowerRails.configure do |bower_rails|
          bower_rails.resolve_before_precompile = true
        end
      end

      it 'should set resolve_before_precompile option' do
        expect(BowerRails.resolve_before_precompile).to eq(true)
      end

      it 'should form correct tasks for enhancing assets:precompile' do
        expect(BowerRails.instance_variable_get(:@tasks)).to eq(['bower:install', 'bower:resolve'])
      end
    end

    describe '#resolve_before_precompile' do
      before do
        BowerRails.configure do |bower_rails|
          bower_rails.clean_before_precompile = true
        end
      end

      it 'should set clean_before_precompile option' do
        expect(BowerRails.clean_before_precompile).to eq(true)
      end

      it 'should form correct tasks for enhancing assets:precompile' do
        expect(BowerRails.instance_variable_get(:@tasks)).to eq(['bower:install', 'bower:clean'])
      end
    end

    describe '#resolve_before_precompile and #clean_before_precompile' do
      before do
        BowerRails.configure do |bower_rails|
          bower_rails.resolve_before_precompile = true
          bower_rails.clean_before_precompile   = true
        end
      end

      it 'should form correct tasks for enhancing assets:precompile' do
        expect(BowerRails.instance_variable_get(:@tasks)).to include('bower:install', 'bower:clean', 'bower:resolve')
      end

      it 'should has three tasks for enhancing' do
        expect(BowerRails.instance_variable_get(:@tasks).size).to eq(3)
      end
    end    
  end
end