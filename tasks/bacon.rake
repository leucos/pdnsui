desc "Runs bacon tests with code coverage"
task :bacon do
  require 'simplecov'
  require 'bacon'

  ENV['RACK_ENV'] = 'spec'

  Bacon.const_set :Backtraces, false unless ENV['BACON_MUTE'].nil? 

  SimpleCov.command_name 'bacon'
  SimpleCov.start do
    add_group "Models", "model/"
    add_group "Controllers", "controller/"
    add_group "Helpers", "helper/"
    add_filter "spec/"
    add_filter "config"
  end if ENV["COVERAGE"] 

  require File.expand_path('spec/init.rb')
end

