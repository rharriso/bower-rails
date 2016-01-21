source "http://rubygems.org"

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
  "~> 4.0.0"
else
  "~> #{rails_version}"
end

gem "rails", rails

gem 'pry'

gemspec

group :test do
  gem 'tins', '~> 1.6.0'
end
