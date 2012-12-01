$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'templator/version'

Gem::Specification.new do |s|
  s.name = "templator"
  s.version = Templator::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.author = "Christophe Arguel"
  s.email = "christophe.arguel@free.fr"
  s.homepage = "https://github.com/carguel/templator"
  s.summary = "A command line tool allowing to generate text documents from ERB template"
  s.description = <<-DESCRIPTION 
  Templator is a command line tool allowing to generate text documents from templates written
  in the ERB template language.

  It also provides a Domain Specific Language, the Parameter DSL, to define a set of parameters
  that can be referenced from template files in order to generate the target document
  with the expected values.
  DESCRIPTION

  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n") - %w[.gitignore .travis.yml]
  s.require_paths = ["lib"]
  s.bindir = 'bin'
  s.executables << 'templator'
  s.extra_rdoc_files = ["CHANGES", "LICENSE", "README.md", "TODO"]
  s.test_files = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ } 

  s.add_development_dependency(%q<bundler>, ["~> 1.2.1"])
  s.add_development_dependency(%q<rake>, [">= 0.9"])
  s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
  s.add_development_dependency(%q<yard>, ["~> 0.8.3"])
  s.add_development_dependency(%q<redcarpet>, ["~> 2.2.2"])
  s.add_runtime_dependency(%q<thor>, ["~>0.16.0"])
end
