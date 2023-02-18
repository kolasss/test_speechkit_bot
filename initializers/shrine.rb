# frozen_string_literal: true

require 'shrine'

if ENV['RACK_ENV'] == 'test'
  require 'shrine/storage/file_system'

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('tmp', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('tmp', prefix: 'uploads/store')
  }
else
  require 'shrine/storage/s3'

  config = YAML.load_file('config/shrine.yml', symbolize_names: true)

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(
      prefix: 'cache', **config
    ),
    store: Shrine::Storage::S3.new(
      prefix: 'store', **config
    )
  }
end

Shrine.plugin :mongoid
Shrine.plugin :remove_invalid
