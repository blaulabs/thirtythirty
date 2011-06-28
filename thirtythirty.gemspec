# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "thirtythirty"
  s.version     = "0.0.8"
  s.date        = Time.now
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Benjamin Behr", "Thomas Jachmann"]
  s.email       = ["benny@digitalbehr.de", "self@thomasjachmann.com"]
  s.homepage    = "http://github.com/blaulabs/thirtythirty"
  s.summary     = %q{Marshalling customization}
  s.description = %q{This gem allows for customization of which data to marshal, especially useful for selective session data serialization.}

  s.rubyforge_project = "thirtythirty"

  s.add_development_dependency "ci_reporter", "~> 1.6.3"
  s.add_development_dependency "rspec", "~> 2.4.0"
  s.add_development_dependency "rake", "0.8.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
