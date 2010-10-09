begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  require 'rspec'
end

begin
  require 'rspec/core/rake_task'

  desc "Run the specs under spec/models"
  RSpec::Core::RakeTask.new do |t|
    # t.rspec_opts = ['--options', "spec/spec.opts"]
  end
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

