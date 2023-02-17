# frozen_string_literal: true

require_relative 'message_sender'
require_relative 'voice_handler'

class SpeechkitBot
  class MessageHandler
    attr_reader :message, :bot

    def initialize(bot, message)
      @bot = bot
      @message = message
    end

    def respond
      case message
      when Telegram::Bot::Types::Message
        if message.voice
          VoiceHandler.new(bot, message).call
        else
          default_message
        end
      else
        default_message
      end
    end

    private

    DEFAULT_MESSAGE_TEXT = 'Этот бот распознает речь. Пожалуйста, пришлите аудио сообщение 😊'

    def default_message
      send_message(DEFAULT_MESSAGE_TEXT)
    end

    def send_message(text)
      MessageSender.new(bot: bot, chat: message.chat).send(text)
    end
  end
end
