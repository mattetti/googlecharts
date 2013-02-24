# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gchart/version"

Gem::Specification.new do |s|
  s.name = %q{googlecharts}
  s.version = GchartInfo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Jorge Alvarez"]
  s.date = %q{2013-02-23}
  s.summary = %q{Generate charts using Google API & Ruby}
  s.description = %q{Generate charts using Google API & Ruby. Based on https://github.com/mattetti/googlecharts}
  s.email = %q{jorge@alvareznavarro.es}
  s.homepage = %q{http://github.com/jorgegorka/googlecharts}
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
end
