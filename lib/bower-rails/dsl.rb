require 'json'
require 'fileutils'

module BowerRails
  class Dsl

    DEFAULT_DEPENDENCY_GROUP = :dependencies

    def self.evalute(root_path, filename)
      new(root_path).tap { |dsl| dsl.eval_file(File.join(root_path, filename)) }
    end

    attr_reader :dependencies, :root_path

    def initialize(root_path)
      @dependency_groups = []
      @root_path = root_path
      @bower_dependencies_list = []
      @dependencies = {}
      @resolutions = {}
      @assets_path ||= "assets"
    end

    def asset(name, *args)
      group = @current_group || default_group
      options = Hash === args.last ? args.pop.dup : {}

      version = args.last || "latest"
      version = options[:ref] if options[:ref]

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
      @dependencies[normalized_group_path][current_dependency_group_normalized] ||= {}
      @dependencies[normalized_group_path][current_dependency_group_normalized][name] = version
    end

    def dependency_group(name, options = {}, &block)

      assert_dependency_group_name name
      add_dependency_group name

      yield if block_given?

      remove_dependency_group!
    end

    def directories
      @dependencies.keys
    end

    def eval_file(file)
      instance_eval(File.open(file, "rb") { |f| f.read }, file.to_s)
    end

    def final_assets_path
      groups.map do |group|
        [group.first.to_s, group_assets_path(group)]
      end.uniq
    end

    def generate_dotbowerrc
      contents = JSON.parse(File.read(File.join(root_path, '.bowerrc'))) rescue {}
      contents["directory"] = "bower_components"
      JSON.pretty_generate(contents)
    end

    def group_assets_path group
      group.last[:assets_path]
    end

    def group(name, options = {}, &block)
      options[:assets_path] ||= @assets_path

      assert_asset_path options[:assets_path]
      assert_group_name name

      @current_group = add_group name, options
      yield if block_given?
    end

    def resolution(name, version)
      @resolutions[name] = version
    end

    def resolutions_with_root
      { :resolutions => @resolutions }
    end

    def write_bower_json
      @dependencies.each do |dir, data|

        FileUtils.mkdir_p dir unless File.directory? dir
        File.open(File.join(dir, "bower.json"), "w") do |f|
          data.merge!(resolutions_with_root)
          f.write(dependencies_to_json(data))
        end
      end
    end

    def write_dotbowerrc
      groups.map do |group|
        normalized_group_path = normalize_location_path(group.first, group_assets_path(group))
        File.open(File.join(normalized_group_path, ".bowerrc"), "w") do |f|
          f.write(generate_dotbowerrc)
        end
      end
    end

    private

    # Stores the dependency group name in the stack
    #
    def add_dependency_group(dependency_group)
      @dependency_groups.push dependency_group.to_sym

      dependency_group
    end

    def add_group(*group)
      @groups = (groups << group) and return group
    end

    def assert_dependency_group_name(name)
      unless [:dependencies, :devDependencies].include?(normalize_dependency_group_name(name))
        raise ArgumentError, "Dependency group should be either dependencies or dev_dependencies, provided: #{name}"
      end
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

    # Returns name for the current dependency from the stack
    #
    def current_dependency_group
      @dependency_groups.last || DEFAULT_DEPENDENCY_GROUP.to_sym
    end

    # Returns normalized current dependency group name
    #
    def current_dependency_group_normalized
      normalize_dependency_group_name current_dependency_group
    end

    def default_group
      [:vendor, { :assets_path => @assets_path }]
    end

    # Attempts to parse data from @dependencies to JSON
    #
    def dependencies_to_json(data)
      JSON.pretty_generate({
        :name => "dsl-generated dependencies"
      }.merge(data))
    end

    def groups
      @groups ||= [default_group]
    end

    # Implementing ActiveSupport::Inflector camelize(:lower)
    #
    def normalize_dependency_group_name(name)
      segments = name.to_s.dup.downcase.split(/_/)
      [segments.shift, *segments.map{ |word| word.capitalize }].join('').to_sym
    end

    def normalize_location_path(loc, assets_path)
      File.join(root_path, loc.to_s, assets_path)
    end

    # Removes the dependency group name in the stack
    #
    def remove_dependency_group!
      @dependency_groups.pop
    end
  end
end
