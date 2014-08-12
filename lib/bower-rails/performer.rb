require 'json'
require 'pp'
require 'find'

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
      entries = Dir.entries(root_path)

      npm_path = File.join(root_path, 'node_modules', '.bin')
      bower = find_command('bower', [npm_path])

      if bower.nil?
        $stderr.puts ["Bower not found! You can install Bower using Node and npm:",
        "$ npm install bower -g",
        "For more info see http://bower.io/"].join("\n")
        return
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
      dot_bowerrc["directory"] = "bower_components"

      if json.except('lib', 'vendor').empty?
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
          FileUtils.rm_rf("bower_components") if remove_components

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

    def resolve_asset_paths
      # Resolve relative paths in CSS
      Dir['bower_components/**/*.css'].each do |filename|
        contents = File.read(filename) if FileTest.file?(filename)
        # http://www.w3.org/TR/CSS2/syndata.html#uri
        url_regex = /url\((?!\#)\s*['"]?(?![a-z]+:)([^'"\)]*)['"]?\s*\)/

        # Resolve paths in CSS file if it contains a url
        if contents =~ url_regex
          directory_path = Pathname.new(File.dirname(filename))
          .relative_path_from(Pathname.new('bower_components'))

          # Replace relative paths in URLs with Rails asset_path helper
          new_contents = contents.gsub(url_regex) do |match|
            relative_path = $1
            image_path = directory_path.join(relative_path).cleanpath
            puts "#{match} => #{image_path}"

            "url(<%= asset_path '#{image_path}' %>)"
          end

          # Replace CSS with ERB CSS file with resolved asset paths
          FileUtils.rm(filename)
          File.write(filename + '.erb', new_contents)
        end
      end
    end

    def remove_extra_files
      puts "\nAttempting to remove all but main files as specified by bower\n"

      Dir['bower_components/*'].each do |component_dir|
        if File.exists?(File.join(component_dir, 'bower.json'))
          bower_file = File.read(File.join(component_dir, 'bower.json'))
        elsif File.exists?(File.join(component_dir, '.bower.json'))
          bower_file = File.read(File.join(component_dir, '.bower.json'))
        else
          next
        end

        # Parse bower.json
        bower_json = JSON.parse(bower_file)
        main_files = bower_json['main']
        next unless main_files

        # Handle singular or multiple files
        main_files = [main_files] unless main_files.is_a?(Array)

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
          return exe if (File.executable?(exe) && File.file?(exe))
        end
      end
      nil
    end

  end
end