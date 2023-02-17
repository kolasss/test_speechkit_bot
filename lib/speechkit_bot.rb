# frozen_string_literal: true

require 'telegram/bot'
require 'yaml'
require_relative 'speechkit_bot/message_handler'

require 'pry'

class SpeechkitBot
  class << self
    def logger
      @logger ||= Logger.new($stdout, Logger::DEBUG)
    end

    def config
      @config ||= load_config
    end

    private

    def load_config
      YAML.load_file('config/secrets.yml', symbolize_names: true)
    end
  end

  def run
    token = SpeechkitBot.config[:telegram_bot_token]
    logger = SpeechkitBot.logger

    Telegram::Bot::Client.run(token, logger: logger) do |bot|
      bot.listen do |message|
        logger.debug "@#{message.from.username}: #{message.text}"
        MessageHandler.new(bot, message).respond
      end
    end
  end

  class Error < StandardError; end
end
