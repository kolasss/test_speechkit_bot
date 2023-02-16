# frozen_string_literal: true

class SpeechkitBot
  class SpeechkitApi
    attr_reader :api_key

    def initialize
      @api_key = SpeechkitBot.config[:speechkit_key]
    end

    def recognize_sync(data)
      response = conn.put('stt:recognize', lang: 'auto') do |request|
        request.headers['Authorization'] = "Api-Key #{api_key}"
        request.body = data
      end

      result = JSON.parse(response.body)
      return result['result'] if response.success?

      result
    end

    private

    def conn
      @conn ||= Faraday.new(url: 'https://stt.api.cloud.yandex.net/speech/v1/') do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
      end
    end
  end
end
