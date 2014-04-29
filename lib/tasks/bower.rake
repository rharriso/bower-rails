require 'json'
require 'pp'
require 'find'

include BeforeHook

namespace :bower do
  desc "Install components from bower"
  task :install, :options do |_, args|
    args.with_defaults(:options => '')
    perform do |bower|
      sh "#{bower} install #{args[:options]}"
    end
  end

  desc "Update bower components"
  task :update, :options do |_, args|
    args.with_defaults(:options => '')
    perform do |bower|
      sh "#{bower} update #{args[:options]}"
    end
  end

  desc "List bower components"
  task :list do
    perform false do |bower|
      sh "#{bower} list"
    end
  end

  namespace :update do
    desc "Update existing components and uninstalls extraneous components"
    task :prune, :options do |_, args|
      args.with_defaults(:options => '')
      perform do |bower|
        sh "#{bower} update #{args[:options]} && #{bower} prune #{args[:options]}"
      end
    end
  end

  desc "Resolve assets paths in bower components"
  task :resolve do
    perform false do
      resolve_asset_paths
    end
  end

  desc "Attempt to keep only files listed in 'main' of each component's bower.json"
  task :clean do
    perform false do
      remove_extra_files
    end
  end
end

before 'assets:precompile' do
  BowerRails.tasks.map do |task|
    Rake::Task[task].invoke
  end
end

def perform remove_components = true, &block
  entries = Dir.entries(get_bower_root_path)

  npm_path = File.join(get_bower_root_path, 'node_modules', '.bin')
  bower = find_command('bower', [npm_path])

  if bower.nil?
    $stderr.puts <<EOS
Bower not found! You can install Bower using Node and npm:
$ npm install bower -g
For more info see http://bower.io/
EOS
    return
  end

  if entries.include?('Bowerfile')
    dsl_perform_command remove_components do
      yield bower if block_given?
    end
  elsif entries.include?('bower.json')
    perform_command remove_components do
      yield bower if block_given?
    end
  else
    raise LoadError, "No Bowerfile or bower.json file found. Make sure you have it at the root of your project"
  end
end

def get_bower_root_path
  Dir.pwd
end

def dsl_perform_command remove_components = true, &block
  dsl = BowerRails::Dsl.evalute("Bowerfile")

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
def perform_command remove_components = true, &block
  bower_root = get_bower_root_path
  #load in bower json file
  txt  = File.read(File.join(bower_root, "bower.json"))
  json = JSON.parse(txt)


  #load and merge root .bowerrc
  dot_bowerrc = JSON.parse(File.read(File.join(bower_root, '.bowerrc'))) rescue {}
  dot_bowerrc["directory"] = "bower_components"

  if json.except('lib', 'vendor').empty?
    folders = json.keys
  else
    raise "Assuming a standard bower package but cannot find the required 'name' key" unless !!json['name']
    folders = ['vendor']
  end

  folders.each do |dir|
    data = json[dir]

    # assume using standard bower.json if folder name is not found
    data = json if data.nil?

    #check folder existence and create?
    dir = File.join(bower_root, dir, "assets")
    FileUtils.mkdir_p dir unless File.directory? dir
    #go in to dir to act
    Dir.chdir(dir) do

      #remove old components
      FileUtils.rm_rf("bower_components") if remove_components

      #create bower json
      File.open("bower.json", "w") do |f|
        f.write(data.to_json)
      end

      #create .bowerrc
      File.open(".bowerrc", "w") do |f|
        f.write(JSON.pretty_generate(dot_bowerrc))
      end

      #run command
      yield  if block_given?

      #remove bower file
      FileUtils.rm("bower.json")

      #remove .bowerrc
      FileUtils.rm(".bowerrc")
    end if data && !data["dependencies"].empty?
  end
end

def resolve_asset_paths
  # Resolve relative paths in CSS
  Dir['bower_components/**/*.css'].each do |filename|
    contents = File.read(filename) if FileTest.file?(filename)
    # http://www.w3.org/TR/CSS2/syndata.html#uri
    url_regex = /url\(\s*['"]?(?![a-z]+:)([^'"\)]*)['"]?\s*\)/

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

    # parse bower.json
    bower_json = JSON.parse(bower_file)
    main_files = bower_json['main']
    next unless main_files

    # handle singular or multiple files
    main_files = [main_files] unless main_files.is_a?(Array)

    # Remove "./" relative path from main file strings
    main_files.map! { |file| File.join(component_dir, file.gsub(/^\.\//, '')) }

    # delete all files that are not in main
    Find.find(component_dir).reverse_each do |file_or_dir|
      next if main_files.include?(file_or_dir)
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
