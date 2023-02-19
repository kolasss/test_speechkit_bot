# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName
class SpeechkitBot
  class TelegramApi
    attr_reader :api, :chat

    def initialize(api: telegram_api)
      @api = api
    end

    def set_webhook(url)
      api.set_webhook(url: url, secret_token: SpeechkitBot.config[:webhook_secret])
    end

    def delete_webhook
      api.delete_webhook
    end

    def get_webhook_info
      api.get_webhook_info
    end

    private

    def telegram_api
      SpeechkitBot.new.telegram_client.api
    end
  end
end
# rubocop:enable Naming/AccessorMethodName
