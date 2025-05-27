# frozen_string_literal: true

require 'yaml'

source 'https://rubygems.org'

ruby '~> 3.2'

group :iro do
  YAML.load_file(File.expand_path('iro-gems.yml', File.dirname(__FILE__)))&.each_pair do |gem_name, config|
    gem gem_name, path: config['path'] if Dir.exist?(config['path'])
  end
end

group :doc do
  gem 'github-markup', require: false
  gem 'redcarpet', require: false
  gem 'webrick', require: false
  gem 'yard', require: false
  gem 'yard-sitemap', require: false
end

group :lint do
  gem 'rubocop', require: false
  gem 'rubocop-ordered_methods', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
  gem 'rubocop-yard', require: false
end

group :test do
  gem 'rspec', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end
