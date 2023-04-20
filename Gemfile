source "https://rubygems.org"

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  { github: "rails/rails" }
when "3.0.0"
  "~> 3.0.0"
when "3.1.0"
  "~> 3.1.0"
when "3.2.0"
  "~> 3.2.0"
when "4.0.0"
  "~> 4.0.0"
when "default"
  "~> 5.2.3"
else
  "~> #{rails_version}"
end

if RUBY_VERSION == '2.7.8'
  gem "racc", "~> 1.4.0"
  gem "nio4r", "~> 2.4.0"
end

gem "rails", rails

gem 'pry'

gemspec

group :test do
  gem 'tins', '~> 1.6.0'
end
