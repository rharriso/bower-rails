module BowerRails
  require 'bower-rails/railtie' if defined?(Rails)
  require 'bower-rails/dsl'

  extend self

  class << self
    # The root path of the project
    attr_accessor :root_path

    # An array of tasks to enhance `rake assets:precompile`
    attr_reader :tasks

    # If set to true then rake bower:install task is invoked before assets precompilation
    attr_accessor :install_before_precompile

    # If set to true then rake bower:install && rake bower:resolve tasks
    # are invoked before assets precompilation
    attr_accessor :resolve_before_precompile

    # If set to true then rake bower:install && rake bower:clean tasks
    # are invoked before assets precompilation
    attr_accessor :clean_before_precompile

    # If set to true then rake bower:install:deployment will be invoked
    # instead of rake bower:install before assets precompilation
    attr_accessor :use_bower_install_deployment

    def configure &block
      yield self if block_given?
      collect_tasks
    end

    private

      def collect_tasks
        install_cmd = 'bower:install'
        install_cmd = 'bower:install:deployment' if @use_bower_install_deployment

        @tasks << [install_cmd] if @install_before_precompile
        @tasks << [install_cmd, 'bower:clean']   if @clean_before_precompile
        @tasks << [install_cmd, 'bower:resolve'] if @resolve_before_precompile
        @tasks.flatten!
        @tasks.uniq!
      end
  end


  # Set default values for options
  @root_path = Dir.pwd
  @tasks = []
  @install_before_precompile    = false
  @resolve_before_precompile    = false
  @clean_before_precompile      = false
  @use_bower_install_deployment = false
end
