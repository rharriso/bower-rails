module BowerRails
  require 'bower-rails/railtie' if defined?(Rails)
  require 'bower-rails/dsl'

  class << self
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

    def enhance_tasks
      Rake::Task['assets:precompile'].enhance(@tasks) unless @tasks.empty?
    end

    private

    def collect_tasks
      @tasks = []
      @tasks << ['bower:install', 'bower:resolve'] if @resolve_before_precompile
      @tasks << ['bower:install', 'bower:clean']   if @clean_before_precompile
      @tasks.flatten!
      @tasks.uniq!
    end
  end

  # Set default values for options
  @resolve_before_precompile = false
  @clean_before_precompile = false
end