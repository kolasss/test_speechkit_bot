# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dry-monads'
gem 'faraday'
gem 'rake'
gem 'sidekiq'
gem 'telegram-bot-ruby'

gem 'aws-sdk-s3', '~> 1.14'
gem 'mongoid'
gem 'shrine-mongoid'

gem 'puma'
gem 'sinatra', '~> 3'

group :development, :test do
  gem 'pry'
  gem 'rspec'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner-mongoid'
  gem 'rack-test'
  gem 'vcr'
  gem 'webmock'
end
