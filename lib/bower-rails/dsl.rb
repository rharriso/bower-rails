require 'json'
require 'fileutils'

module BowerRails
  class Dsl
    cattr_accessor :config
    attr_reader :dependencies

    def self.evalute(file)
      inst = new
      inst.eval_file(file)
      inst
    end

    def initialize
      @dependencies = {}
      @groups = []
      @root_path = BowerRails::Dsl.config[:root_path] ||  File.expand_path("./")
      @assets_path = BowerRails::Dsl.config[:assets_path] ||  "/assets/javascripts"
    end

    def eval_file(file)
      contents = File.open(file, "r").read
      instance_eval(contents, file.to_s, 1)
    end

    def directories
      @dependencies.keys
    end

    def group(*args, &blk)
      @groups.concat [args]
      yield
    ensure
      args.each { @groups.pop }
    end

    def js(name, *args)
      options = Hash === args.last ? args.pop : {}
      version = args.first || "latest"

      @groups = ["lib"] if @groups.empty?

      @groups.each do |g|
        g_options = Hash === g.last ? g.pop : {}
        assets_path = g_options[:assets_path] || @assets_path

        g_norm = normalize_location_path(g.first,assets_path)
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
        File.open(File.join(dir,"bower.json"),"w") do |f|
          f.write(dependencies_to_json(data))
        end
      end
    end

    private

    def dependencies_to_json(data)
       JSON.pretty_generate({
          :dependencies => data
        })
    end

    def assets_path(assets_path)
      @assets_path = assets_path
    end

    def normalize_location_path(loc,assets_path)
      File.join(@root_path,loc.to_s,assets_path)
    end

  end
end
