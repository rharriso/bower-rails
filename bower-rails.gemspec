$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bower-rails/version"

Gem::Specification.new do |s|
  s.name          = "bower-rails"
  s.homepage      = "https://github.com/rharriso/bower-rails"
  s.version       = BowerRails::VERSION
  s.date          = "2013-12-12"
  s.summary       = "Bower for Rails"
  s.description   = "Rails integration for bower."
  s.authors       = ["Ross Harrison"]
  s.email         = "rtharrison86@gmail.com"
  s.files         = Dir["lib/**/*"] + ["MIT-LICENSE", "README.md"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.license    = 'MIT'

  s.add_dependency "bowerify"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "coveralls"
end
