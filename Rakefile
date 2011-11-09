require 'rake/gempackagetask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)


spec = Gem::Specification.load('templator.gemspec')
Rake::GemPackageTask.new(spec).define

