# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gchart/version"

Gem::Specification.new do |s|
  s.name = %q{googlecharts}
  s.version = GchartInfo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Matt Aimonetti", "Andrey Deryabin"]
  s.date = %q{2011-05-21}
  s.summary = %q{Generate charts using Google API & Ruby}
  s.description = %q{Generate charts using Google API & Ruby}
  s.email = %q{mattaimonetti@gmail.com deriabin@gmail.com}
  s.homepage = %q{http://googlecharts.rubyforge.org/}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
