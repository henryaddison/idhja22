require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

desc "Run specs with SimpleCov"
RSpec::Core::RakeTask.new('coverage') do |t|
  ENV['COVERAGE'] = "true"
end

task :default => :spec
