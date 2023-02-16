# frozen_string_literal: true

require_relative 'speechkit_api'
require_relative 'message_sender'

class SpeechkitBot
  class VoiceHandler
    attr_reader :message, :bot

    def initialize(bot, message)
      @bot = bot
      @message = message
    end

    def call
      raise Error, 'Not a voice message' unless message.voice

      data = download_data
      text = call_speechkit(data)
      send_message(text)
    rescue Error => e
      SpeechkitBot.logger.error "ERROR: #{e.message}"
      send_message(e.message)
    end

    private

    def download_data
      file_path = get_file_path
      get_data(file_path)
    end

    def get_file_path
      result = bot.api.get_file(file_id: message.voice.file_id)
      raise 'Can\'t get file path' unless result['ok']

      result['result']['file_path']
    end

    def get_data(file_path)
      result = conn.get(build_path(file_path))
      raise 'Can\'t download file' unless result.success?

      result.body
    end

    # https://api.telegram.org/file/bot<token>/<file_path>
    def build_path(file_path)
      "/file/bot#{bot.api.token}/#{file_path}"
    end

    def conn
      bot.api.send(:conn)
    end

    def call_speechkit(data)
      SpeechkitApi.new.recognize_sync(data)
    end

    def send_message(text)
      MessageSender.new(bot: bot, chat: message.chat).send(text)
    end
  end
end
