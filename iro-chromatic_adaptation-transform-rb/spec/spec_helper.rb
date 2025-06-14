# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov.start do
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::LcovFormatter, SimpleCov::Formatter::HTMLFormatter],
  )
  add_filter 'spec'
  track_files 'lib/**/*.rb'
end

require 'rspec'
require 'iro-chromatic_adaptation-transform'

Dir.glob(File.expand_path('support/**/*.rb', File.dirname(__FILE__))).each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'logs/rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed
end
