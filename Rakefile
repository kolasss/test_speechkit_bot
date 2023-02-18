# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

spec = Gem::Specification.find_by_name 'mongoid'
load "#{spec.gem_dir}/lib/mongoid/tasks/database.rake"

task :environment do
  ENV['RACK_ENV'] ||= 'development'

  require 'bundler/setup'
  require './lib/speechkit_bot'
end
