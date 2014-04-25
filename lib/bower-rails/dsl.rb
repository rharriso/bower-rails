require 'json'
require 'fileutils'

module BowerRails
  class Dsl

    def self.evalute(filename)
      new.tap { |dsl| dsl.eval_file(File.join(dsl.root_path, filename)) }
    end

    attr_reader :dependencies, :root_path

    def initialize
      @dependencies = {}
      @root_path ||= Dir.pwd
      @assets_path ||= "assets"
    end

    def eval_file(file)
      instance_eval(File.open(file, "rb") { |f| f.read }, file.to_s)
    end

    def directories
      @dependencies.keys
    end

    def group(name, options = {}, &block)
      options[:assets_path] ||= @assets_path

      assert_asset_path options[:assets_path]
      assert_group_name name

      @current_group = add_group name, options
      yield if block_given?
    end

    def asset(name, *args)
      group = @current_group || default_group

      options = Hash === args.last ? args.pop.dup : {}
      version = args.last || "latest"

      options[:git] = "git://github.com/#{options[:github]}" if options[:github]

      if options[:git]
        version = if version == 'latest'
                    options[:git]
                  else
                    options[:git] + "#" + version
                  end
      end

      normalized_group_path = normalize_location_path(group.first, group_assets_path(group))
      @dependencies[normalized_group_path] ||= {}
      @dependencies[normalized_group_path][name] = version
    end

    def write_bower_json
      @dependencies.each do |dir, data|
        FileUtils.mkdir_p dir unless File.directory? dir
        File.open(File.join(dir, "bower.json"), "w") do |f|
          f.write(dependencies_to_json(data))
        end
      end
    end

    def generate_dotbowerrc
      contents = JSON.parse(File.read(File.join(@root_path, '.bowerrc'))) rescue {}
      contents["directory"] = "bower_components"
      JSON.pretty_generate(contents)
    end

    def write_dotbowerrc
      groups.map do |group|
        normalized_group_path = normalize_location_path(group.first, group_assets_path(group))
        File.open(File.join(normalized_group_path, ".bowerrc"), "w") do |f|
          f.write(generate_dotbowerrc)
        end
      end
    end

    def final_assets_path
      groups.map do |group|
        [group.first.to_s, group_assets_path(group)]
      end
    end

    def group_assets_path group
      group.last[:assets_path]
    end

    private

    def add_group(*group)
      @groups = (groups << group) and return group
    end

    def groups
      @groups ||= [default_group]
    end

    def default_group
      [:vendor, { :assets_path => @assets_path }]
    end

    def dependencies_to_json(data)
      JSON.pretty_generate({
        :name => "dsl-generated dependencies",
        :dependencies => data
      })
    end

    def assets_path(assets_path)
      assert_asset_path assets_path
      @assets_path = assets_path
    end

    def assert_asset_path(path)
      unless path.start_with?('assets', '/assets')
        raise ArgumentError, "Assets should be stored in /assets directory, try assets_path 'assets/#{path}' instead"
      end
    end

    def assert_group_name name
      raise ArgumentError, "Group name should be :lib or :vendor only" unless [:lib, :vendor].include?(name)
    end

    def normalize_location_path(loc, assets_path)
      File.join(@root_path, loc.to_s, assets_path)
    end
  end
end
