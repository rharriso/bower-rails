require 'json'
require 'pp'
require 'find'
require 'shellwords'

module BowerRails
  class Performer
    include FileUtils

    def self.perform(*args, &block)
      new.perform(*args, &block)
    end

    def root_path
      BowerRails.root_path
    end

    def perform(remove_components = true, &block)
      npm_path = File.join(root_path, 'node_modules', '.bin')
      bower = find_command('bower', [npm_path])

      if bower.nil?
        $stderr.puts ["Bower not found! You can install Bower using Node and npm:",
        "$ npm install bower -g",
        "For more info see http://bower.io/"].join("\n")
        exit 127
      end

      if entries.include?('Bowerfile')
        dsl_perform_command remove_components do
          instance_exec(bower, &block) if block_given?
        end
      elsif entries.include?('bower.json')
        perform_command remove_components do
          instance_exec(bower, &block) if block_given?
        end
      else
        raise LoadError, "No Bowerfile or bower.json file found. Make sure you have it at the root of your project"
      end
    end

    def dsl
      @dsl ||= BowerRails::Dsl.evalute(root_path, "Bowerfile")
    end

    def dsl_perform_command(remove_components = true, &block)
      if remove_components
        dsl.write_bower_json
        dsl.write_dotbowerrc
        puts "bower.js files generated"
      end

      if block_given?
        dsl.directories.each do |dir|
          Dir.chdir(dir) do
            yield
          end
        end
      end
    end

    #run the passed bower block in appropriate folders
    def perform_command(remove_components = true, &block)
      # Load in bower json file
      txt  = File.read(File.join(root_path, "bower.json"))
      json = JSON.parse(txt)


      # Load and merge root .bowerrc
      dot_bowerrc = JSON.parse(File.read(File.join(root_path, '.bowerrc'))) rescue {}
      dot_bowerrc["directory"] = components_directory

      if json.reject{ |key| ['lib', 'vendor'].include? key }.empty?
        folders = json.keys
      else
        raise "Assuming a standard bower package but cannot find the required 'name' key" unless !!json['name']
        folders = ['vendor']
      end

      folders.each do |dir|
        data = json[dir]

        # Assume using standard bower.json if folder name is not found
        data = json if data.nil?

        # Check folder existence and create?
        dir = File.join(root_path, dir, "assets")
        FileUtils.mkdir_p dir unless File.directory? dir
        # Go in to dir to act
        Dir.chdir(dir) do

          # Remove old components
          FileUtils.rm_rf("#{components_directory}/*") if remove_components

          # Create bower.json
          File.open("bower.json", "w") do |f|
            f.write(data.to_json)
          end

          # Create .bowerrc
          File.open(".bowerrc", "w") do |f|
            f.write(JSON.pretty_generate(dot_bowerrc))
          end

          # Run command
          yield  if block_given?

          # Remove bower.json
          FileUtils.rm("bower.json")

          # Remove .bowerrc
          FileUtils.rm(".bowerrc")
        end if data && !data["dependencies"].empty?
      end
    end

    def resolve_asset_paths(root_directory = components_directory)
      # Resolve relative paths in CSS
      Dir["#{components_directory}/**/*.css"].each do |filename|
        contents = File.read(filename) if FileTest.file?(filename)
        # http://www.w3.org/TR/CSS2/syndata.html#uri
        url_regex = /url\((?!\#)\s*['"]?((?![a-z]+:)([^'"\)]*?)([?#][^'"\)]*)?)['"]?\s*\)/

        # Resolve paths in CSS file if it contains a url
        if contents =~ url_regex
          directory_path = Pathname.new(File.dirname(filename))
          .relative_path_from(Pathname.new(root_directory))

          # Replace relative paths in URLs with Rails asset_path helper
          new_contents = contents.gsub(url_regex) do |match|
            relative_path = $2
            params = $3
            image_path = directory_path.join(relative_path).cleanpath
            puts "#{match} => #{image_path} #{params}"

            "url(<%= asset_path '#{image_path}' %>#{params})"
          end

          # Replace CSS with ERB CSS file with resolved asset paths
          FileUtils.rm(filename)
          File.write(filename + '.erb', new_contents)
        end
      end
    end

    def remove_extra_files
      puts "\nAttempting to remove all but main files as specified by bower\n"

      Dir["#{components_directory}/*"].each do |component_dir|
        component_name = component_dir.split('/').last
        next if clean_should_skip_component? component_name

        if File.exist?(File.join(component_dir, 'bower.json'))
          bower_file = File.read(File.join(component_dir, 'bower.json'))
        elsif File.exist?(File.join(component_dir, '.bower.json'))
          bower_file = File.read(File.join(component_dir, '.bower.json'))
        else
          next
        end

        # Parse bower.json
        bower_json = JSON.parse(bower_file)
        main_files = Array(bower_json['main']) + main_files_for_component(component_name)
        next if main_files.empty?

        # Remove "./" relative path from main file strings
        main_files.map! { |file| File.join(component_dir, file.gsub(/^\.\//, '')) }

        # Make Regexp to handle wildcards
        main_files.map! { |file| Regexp.new("\\A" + file.gsub(/\*/, '.*') + "\\Z") }

        # Delete all files that are not in main
        Find.find(component_dir).reverse_each do |file_or_dir|
          next if main_files.any? { |pattern| file_or_dir =~ pattern }
          if File.directory?(file_or_dir)
            Dir.rmdir(file_or_dir) if (Dir.entries(file_or_dir) - %w[ . .. ]).empty?
          else
            FileUtils.rm(file_or_dir)
          end
        end
      end
    end

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def find_command(cmd, paths = [])
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      paths += ENV['PATH'].split(File::PATH_SEPARATOR)
      paths.each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          if (File.executable?(exe) && File.file?(exe))
            return Shellwords.escape exe
          end
        end
      end
      nil
    end

    private

    def main_files_for_component(name)
      return [] unless entries.include?('Bowerfile')
      Array(dsl.main_files[name])
    end

    def entries
      @entries ||= Dir.entries(root_path)
    end

    def clean_should_skip_component?(name)
      BowerRails.exclude_from_clean.respond_to?(:include?) &&
        BowerRails.exclude_from_clean.include?(name)
    end

    def components_directory
      BowerRails.bower_components_directory
    end
  end
end
