module BowerRails
  require 'bower-rails/railtie' if defined?(Rails)
  require 'bower-rails/dsl'

  class << self
    # If set to true then rake bower:install && rake bower:resolve tasks
    # are invoked before assets precompilation
    attr_accessor :resolve_before_precompile

    def configure &block
      yield self if block_given?
    end
  end

  # Set default values for options
  @resolve_before_precompile = false
end