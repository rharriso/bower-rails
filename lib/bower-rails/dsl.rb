require 'json'
require 'fileutils'

module BowerRails
  class Dsl
    def self.evalute(filename)
      instance = new
      instance.eval_file(File.join(instance.root_path, filename))
      instance
    end

    attr_reader :dependencies, :root_path

    def initialize
      @dependencies = {}
      @root_path ||= defined?(Rails) ? Rails.root : Dir.pwd
      @assets_path ||= "assets"
      @groups ||= [[:vendor, { assets_path: @assets_path }]]
    end

    def eval_file(file)
      instance_eval(File.open(file, "rb") { |f| f.read }, file.to_s)
    end

    def directories
      @dependencies.keys
    end

    def group(*args, &block)
      if args[1]
        custom_assets_path = args[1][:assets_path]
        raise ArgumentError, "Assets should be stored in /assets directory, try :assets_path => 'assets/#{custom_assets_path}' instead" unless custom_assets_path.start_with?('assets', '/assets')
        new_group = [args[0], args[1]]
      else
        new_group = [args[0]]
      end
        
      @groups << new_group

      yield if block_given?
    end

    def asset(name, *args)
      version = args.first || "latest"

      @groups.each do |g|
        g_norm = normalize_location_path(g.first, group_assets_path(g))
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
      @groups.map do |g|
        g_norm = normalize_location_path(g.first, group_assets_path(g))
        File.open(File.join(g_norm, ".bowerrc"), "w") do |f|
          f.write(JSON.pretty_generate({:directory => "bower_components"}))
        end
      end
    end

    def final_assets_path
      @groups.map do |g|
        [g.first.to_s, group_assets_path(g)]
      end
    end   

    def group_assets_path group
      group_options = Hash === group.last ? group.last : {:assets_path => @assets_path}
      group_options[:assets_path]
    end 

    private

    def dependencies_to_json(data)
      JSON.pretty_generate({
        :name => "dsl-generated dependencies",
        :dependencies => data
      })
    end

    def assets_path(assets_path)
      raise ArgumentError, "Assets should be stored in /assets directory, try assets_path 'assets/#{assets_path}' instead" unless assets_path.start_with?('assets', '/assets')
      @assets_path = assets_path
    end

    def normalize_location_path(loc, assets_path)
      File.join(@root_path, loc.to_s, assets_path)
    end
  end
end
