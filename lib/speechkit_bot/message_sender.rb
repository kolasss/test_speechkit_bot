# frozen_string_literal: true

class SpeechkitBot
  class MessageSender
    attr_reader :api, :chat

    def initialize(chat:, api: telegram_api)
      @api = api
      @chat = chat
    end

    def send(text)
      SpeechkitBot.logger.debug "sending '#{text}' to #{chat.username}"
      api.send_message(chat_id: chat.id, text: text)
    end

    private

    def telegram_api
      @telegram_api ||= SpeechkitBot.new.telegram_client.api
    end
  end
end
