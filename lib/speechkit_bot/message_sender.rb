# frozen_string_literal: true

class SpeechkitBot
  class MessageSender
    attr_reader :bot, :chat

    def initialize(bot:, chat:)
      @bot = bot
      @chat = chat
    end

    def send(text)
      SpeechkitBot.logger.debug "sending '#{text}' to #{chat.username}"
      bot.api.send_message(chat_id: chat.id, text: text)
    end
  end
end
