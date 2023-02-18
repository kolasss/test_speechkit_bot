# frozen_string_literal: true

require 'dry/monads'

module SpeechkitBot::Operations
  class ProcessFile
    include Dry::Monads[:result, :do]

    def call(voice_task)
      data = yield download_data(voice_task.message_data)
      save_file_to_storage(voice_task, data)
    end

    private

    def download_data(message_data)
      file_path = yield get_file_path(message_data)
      download_file(file_path)
    end

    def get_file_path(message_data)
      result = api.get_file(file_id: message_data[:voice][:file_id])
      return Failure('Can\'t get file path') unless result['ok']

      Success(result['result']['file_path'])
    end

    def download_file(file_path)
      result = conn.get(build_path(file_path))
      return Failure('Can\'t download file') unless result.success?

      Success(result.body)
    end

    # https://api.telegram.org/file/bot<token>/<file_path>
    def build_path(file_path)
      "/file/bot#{api.token}/#{file_path}"
    end

    def conn
      api.send(:conn)
    end

    def save_file_to_storage(voice_task, data)
      voice_task.voice_message = StringIO.new(data)
      cached_file = voice_task.voice_message
      cached_file.metadata['filename'] = 'voice_message.oga'
      voice_task.voice_message = cached_file.to_json

      voice_task.status = 'file_saved'

      if voice_task.save
        Success(voice_task)
      else
        Failure(voice_task.errors.full_messages)
      end
    end

    def api
      @api ||= SpeechkitBot.new.telegram_client.api
    end
  end
end
