require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |task|
    task.pattern = "**/spec/*_spec.rb"
    task.rspec_opts = []
    task.rspec_opts << '--color'
    task.rspec_opts << '-f documentation'
end