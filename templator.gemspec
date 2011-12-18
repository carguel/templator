Gem::Specification.new do |s|
  s.name = "templator"
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.author = "Christophe Arguel"
  s.email = "christophe.arguel@free.fr"
  s.homepage = "https://github.com/carguel/templator"
  s.summary = "A command line tool allowing to generate text documents from ERB template"
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.platform = Gem::Platform::RUBY
  s.files = Dir['[A-Z]*', 'lib/**/*']
  s.require_paths = ["lib"]
  s.bindir = 'bin'
  s.executables << 'templator'
  s.extra_rdoc_files = ["CHANGES", "LICENSE", "README.md", "TODO"]
  s.test_files = Dir['spec/**/*_spec.rb']

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, [">= 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.7"])
      s.add_development_dependency(%q<yard>, ["~> 0.7.3"])
      s.add_runtime_dependency(%q<thor>, ["~>0.14.6"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<rake>, [">= 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.7"])
      s.add_dependency(%q<yard>, ["~> 0.7.3"])
      s.add_dependency(%q<thor>, ["~>0.14.6"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<rake>, [">= 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.7"])
    s.add_dependency(%q<yard>, ["~> 0.7.3"])
    s.add_dependency(%q<thor>, ["~>0.14.6"])
  end
end
