require 'json'
require 'fileutils'

module BowerRails
  class Dsl
    cattr_accessor :config
    attr_reader :dependencies

    def self.evalute(file)
      instance = new
      instance.eval_file(file)
      instance
    end

    def initialize
      @dependencies = {}
      @groups = []
      @root_path = BowerRails::Dsl.config[:root_path] ||  File.expand_path("./")
      @assets_path = BowerRails::Dsl.config[:assets_path] ||  "assets"
    end

    def eval_file(file)
      instance_eval(File.open(file, "rb") { |f| f.read }, file.to_s)
    end

    def directories
      @dependencies.keys
    end

    def group(*args, &blk)
      if args[1]
        custom_assets_path = args[1][:assets_path]
        raise ArgumentError, "Assets should be stored in /assets directory, try :assets_path => 'assets/#{custom_assets_path}' instead" if custom_assets_path.match(/assets/).nil?
        new_group = [args[0], args[1]]
      else
        new_group = [args[0]]
      end
      
      @groups << new_group
      yield
    end

    def js(name, *args)
      version = args.first || "latest"
      @groups = [[:vendor, { assets_path: @assets_path }]] if @groups.empty?

      @groups.each do |g|
        g_norm = normalize_location_path(g.first.to_s, group_assets_path(g))
        @dependencies[g_norm] ||= {}
        @dependencies[g_norm][name] = version
      end
    end

    def to_json(location)
      dependencies_to_json @dependencies[normalize_location_path(location)]
    end

    def write_bower_json
      @dependencies.each do |dir,data|
        FileUtils.mkdir_p dir unless File.directory? dir
        File.open(File.join(dir,"bower.json"), "w") do |f|
          f.write(dependencies_to_json(data))
        end
      end
    end

    def write_dotbowerrc
      @groups = [[:vendor, { assets_path: @assets_path }]] if @groups.empty?
      @groups.map do |g|
        File.open(File.join(g.first.to_s, group_assets_path(g), ".bowerrc"), "w") do |f|
          f.write(JSON.pretty_generate({:directory => "bower_components"}))
        end
      end
    end

    def final_assets_path
      @groups = [[:vendor, { assets_path: @assets_path }]] if @groups.empty? 
      @groups.map do |g|
        [g.first.to_s, group_assets_path(g)]
      end
    end   

    def group_assets_path group
      group_options = Hash === group.last ? group.pop : {}
      group_options[:assets_path] || @assets_path 
    end 

    private

    def dependencies_to_json(data)
      JSON.pretty_generate({
        :name => "dsl-generated dependencies",
        :dependencies => data
      })
    end

    def assets_path(assets_path)
      raise ArgumentError, "Assets should be stored in /assets directory, try assets_path 'assets/#{assets_path}' instead" if assets_path.match(/assets/).nil?
      @assets_path = assets_path
    end

    def normalize_location_path(loc, assets_path)
      File.join(@root_path, loc.to_s, assets_path)
    end

  end
end
