module BowerRails
  require 'bower-rails/railtie' if defined?(Rails)
  require 'bower-rails/dsl'

  extend self

  class << self
    # An array of tasks to enhance `rake assets:precompile`
    attr_reader :tasks
    
    # If set to true then rake bower:install && rake bower:resolve tasks
    # are invoked before assets precompilation
    attr_accessor :resolve_before_precompile

    # If set to true then rake bower:install && rake bower:clean && rake bower:resolve tasks
    # are invoked before assets precompilation
    attr_accessor :clean_before_precompile

    def configure &block
      yield self if block_given?
      collect_tasks
    end

    private

      def collect_tasks
        @tasks << ['bower:install', 'bower:resolve'] if @resolve_before_precompile
        @tasks << ['bower:install', 'bower:clean']   if @clean_before_precompile
        @tasks.flatten!
        @tasks.uniq!
      end
  end

  # By default tasks are empty
  @tasks = []

  # Set default values for options
  @resolve_before_precompile = false
  @clean_before_precompile = false
end