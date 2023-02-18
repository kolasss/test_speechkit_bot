# frozen_string_literal: true

class SpeechkitBot
  class SpeechkitApi
    attr_reader :api_key

    def initialize
      @api_key = SpeechkitBot.config[:speechkit_key]
    end

    # https://stt.api.cloud.yandex.net/speech/v1/stt:recognize
    def recognize_sync(data)
      response = conn_sync.post('stt:recognize') do |request|
        request.body = data
      end

      result = JSON.parse(response.body)
      return result['result'] if response.success?

      result
    end

    # https://transcribe.api.cloud.yandex.net/speech/stt/v2/longRunningRecognize
    def recognize_async(url)
      response = conn_async.post('longRunningRecognize') do |request|
        request.body = async_params(url).to_json
      end

      return JSON.parse(response.body) if response.success?

      { error: response }
    end

    # https://operation.api.cloud.yandex.net/operations/{operationId}
    def recognition_operation_status(id)
      response = conn_operation.get("operations/#{id}")

      return JSON.parse(response.body) if response.success?

      { error: response }
    end

    private

    def async_params(url)
      {
        config: {
          specification: {
            languageCode: 'auto'
          }
        },
        audio: {
          uri: remove_url_params(url)
        }
      }
    end

    def remove_url_params(url)
      uri = URI.parse(url)
      uri.query = nil
      uri.to_s
    end

    def conn_sync
      @conn_sync ||= Faraday.new(url: 'https://stt.api.cloud.yandex.net/speech/v1/', headers: default_headers)
    end

    def conn_async
      @conn_async ||= Faraday.new(
        url: 'https://transcribe.api.cloud.yandex.net/speech/stt/v2/',
        headers: default_headers
      )
    end

    def conn_operation
      @conn_operation ||= Faraday.new(url: 'https://operation.api.cloud.yandex.net/', headers: default_headers)
    end

    def default_headers
      {
        'Authorization' => "Api-Key #{api_key}"
      }
    end
  end
end
