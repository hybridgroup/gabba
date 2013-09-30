# -*- encoding: utf-8 -*-
require File.expand_path '../lib/gabba/version', __FILE__

Gem::Specification.new do |s|
  s.name        = "gabba"
  s.version     = Gabba::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ron Evans"]
  s.email       = ["ron dot evans at gmail dot com"]
  s.homepage    = "https://github.com/hybridgroup/gabba"
  s.summary     = %q{Easy server-side tracking for Google Analytics}
  s.description = %q{Easy server-side tracking for Google Analytics}
  s.license = "MIT"

  s.rubyforge_project = "gabba"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'net-http-persistent', '~> 2.9'
  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'minitest', '~> 5.0.7'
  s.add_development_dependency 'webmock', '~> 1.13.0'
end
