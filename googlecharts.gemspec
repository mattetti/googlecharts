Gem::Specification.new do |s|
  s.name = %q{googlecharts}
  s.version = "1.3.5"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Aimonetti"]
  s.date = %q{2008-05-07}
  s.description = %q{Sexy Charts using Google API & Ruby}
  s.email = %q{mattaimonetti@gmail.com}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "website/index.txt"]
  s.files = %w(History.txt License.txt Manifest.txt README README.markdown README.txt Rakefile config config/hoe.rb config/requirements.rb lib lib/gchart lib/gchart.rb lib/gchart/aliases.rb lib/gchart/theme.rb lib/gchart/version.rb lib/themes.yml script script/destroy script/generate script/txt2html setup.rb spec spec/fixtures spec/fixtures/another_test_theme.yml spec/fixtures/test_theme.yml spec/gchart_spec.rb spec/spec.opts spec/spec_helper.rb spec/theme_spec.rb tasks tasks/deployment.rake tasks/environment.rake tasks/rspec.rake tasks/website.rake website website/index.html website/index.txt website/javascripts website/javascripts/rounded_corners_lite.inc.js website/stylesheets website/stylesheets/screen.css website/template.rhtml)
  s.has_rdoc = true
  s.homepage = %q{http://googlecharts.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{googlecharts}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Sexy Charts using Google API & Ruby}
end