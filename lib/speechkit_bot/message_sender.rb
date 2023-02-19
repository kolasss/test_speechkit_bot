# frozen_string_literal: true

class SpeechkitBot
  class MessageSender
    attr_reader :api, :chat

    def initialize(chat:, api: telegram_api)
      @api = api
      @chat = chat
    end

    def send(text, reply_to_message_id: nil)
      SpeechkitBot.logger.debug "sending '#{text}' to #{chat.username}"
      params = { chat_id: chat.id, text: text }
      params[:reply_to_message_id] = reply_to_message_id if reply_to_message_id
      api.send_message(**params)
    end

    private

    def telegram_api
      SpeechkitBot.new.telegram_client.api
    end
  end
end
