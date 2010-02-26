require 'rubygems'  
require 'rake'

begin  
  require 'jeweler'  
  Jeweler::Tasks.new do |gemspec|  
    gemspec.name = "googlecharts"  
    gemspec.summary = "Generate charts using Google API & Ruby"  
    gemspec.description = "Generate charts using Google API & Ruby"  
    gemspec.email = "mattaimonetti@gmail.com"  
    gemspec.homepage = "http://googlecharts.rubyforge.org/"  
    gemspec.authors = ["Matt Aimonetti"]  
  end 
  Jeweler::GemcutterTasks.new 
rescue LoadError  
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"  
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

