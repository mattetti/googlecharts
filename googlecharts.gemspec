Gem::Specification.new do |s|
  s.name = %q{googlecharts}
  s.version = "1.3.6"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Aimonetti"]
  s.date = %q{2008-05-07}
  s.description = %q{Sexy Charts using Google API & Ruby}
  s.email = %q{mattaimonetti@gmail.com}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "website/index.txt"]
  s.files = %w(History.txt License.txt Manifest.txt README.txt Rakefile config/hoe.rb config/requirements.rb lib/gchart.rb lib/gchart/aliases.rb lib/gchart/theme.rb lib/themes.yml lib/gchart/version.rb setup.rb spec/gchart_spec.rb spec/spec.opts spec/spec_helper.rb tasks/environment.rake tasks/rspec.rake)
  s.has_rdoc = true
  s.homepage = %q{http://googlecharts.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{googlecharts}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Sexy Charts using Google API & Ruby}
end