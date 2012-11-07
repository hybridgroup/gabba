# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gabba/version"

Gem::Specification.new do |s|
  s.name        = "gabba"
  s.version     = Gabba::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ron Evans"]
  s.email       = ["ron dot evans at gmail dot com"]
  s.homepage    = "https://github.com/hybridgroup/gabba"
  s.summary     = %q{Easy server-side tracking for Google Analytics}
  s.description = %q{Easy server-side tracking for Google Analytics}

  s.rubyforge_project = "gabba"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
