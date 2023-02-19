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

namespace :webhook do
  require './lib/speechkit_bot/telegram_api'

  desc 'Set webhook url'
  task :set, [:url] => :environment do |_task, args|
    url = args[:url]
    abort('url param is missing') unless url

    puts SpeechkitBot::TelegramApi.new.set_webhook(url)
  end

  desc 'Delete webhook'
  task delete: :environment do
    puts SpeechkitBot::TelegramApi.new.delete_webhook
  end

  desc 'Show webhook info'
  task get: :environment do
    puts SpeechkitBot::TelegramApi.new.get_webhook_info
  end
end
