# frozen_string_literal: true

require 'telegram/bot'
require 'yaml'
require_relative '../initializers/mongoid'
require_relative '../initializers/shrine'
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
    bot = telegram_client
    bot.listen do |message|
      SpeechkitBot.logger.debug "@#{message.from.username}: #{message.text}"
      MessageHandler.new(bot, message).respond
    end
  end

  def telegram_client
    token = SpeechkitBot.config[:telegram_bot_token]
    logger = SpeechkitBot.logger

    Telegram::Bot::Client.new(token, logger: logger)
  end

  class Error < StandardError; end
end
