# frozen_string_literal: true

Gem::Specification.new do |spec|
  gem_version = '0.1.0'
  semver      = '0.1.0'
  repo_url    = 'https://github.com/iro-lib/iro-support-rb'
  home_url    = 'https://iro-lib.com'

  spec.name        = 'iro-support'
  spec.version     = gem_version
  spec.homepage    = home_url
  spec.authors     = ['Aaron Allen']
  spec.email       = ['hello@aaronmallen.me']
  # TODO: Add a summary and a description for the gem
  spec.summary     = 'iro-support'
  spec.description = 'iro-support description'

  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.2'

  spec.files = Dir.chdir(__dir__) do
    Dir['lib/**/*', '.yardopts', 'LICENSE', 'README.md'].reject { |f| File.directory?(f) }
  end

  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{repo_url}/issues",
    'changelog_uri' => "#{repo_url}/releases/tag/#{semver}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{repo_url}/tree/#{semver}",
  }

  spec.add_dependency 'zeitwerk', '~> 2.7'
end
