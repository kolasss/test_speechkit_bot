# frozen_string_literal: true

require './lib/speechkit_app'

RSpec.describe SpeechkitApp do
  include Rack::Test::Methods

  def app
    SpeechkitApp
  end

  describe 'GET /' do
    it 'returns ok' do
      get '/'
      expect(last_response.body).to eq('this is speechkit bot app')
      expect(last_response.status).to eq 200
    end
  end

  describe 'POST /webhook' do
    before do
      header 'X-Telegram-Bot-Api-Secret-Token', token
    end

    context 'with wrong token' do
      let(:token) { nil }

      it 'returns Unauthorized' do
        post '/webhook', 'body'
        expect(last_response.status).to eq 401
      end
    end

    context 'with right token' do
      let(:token) { SpeechkitBot.config[:webhook_secret] }
      let(:body) do
        '{
          "update_id": 61510816,
          "message": {
            "message_id": 86,
            "from": {
              "id": 71043908,
              "is_bot": false,
              "first_name": "user_test_name",
              "username": "test_name",
              "language_code": "ru"
            },
            "chat": {
              "id": 71043908,
              "first_name": "user_test_name",
              "username": "test_name",
              "type": "private"
            },
            "date": 1676739412,
            "voice": {
              "duration": 1,
              "mime_type": "audio/ogg",
              "file_id": "AwACAgIAAxkBAANWY_EDVBKC9a4dgAkhZV7EgPk4hDEAAocjAAIapYBLHz_1yie2ERwuBA",
              "file_unique_id": "AgADhyMAAhqlgEs",
              "file_size": 35480
            }
          }
        }'
      end
      let(:handler) { double }

      before do
        allow(SpeechkitBot::MessageHandler).to receive(:new).and_return(handler)
        allow(handler).to receive(:respond)

        post '/webhook', body
      end

      it 'returns ok' do
        expect(last_response.body).to eq('')
        expect(last_response.status).to eq 200
      end

      it 'calls MessageHandler' do
        expect(SpeechkitBot::MessageHandler).to have_received(:new)
          .with(instance_of(Telegram::Bot::Api), instance_of(Telegram::Bot::Types::Message))
        expect(handler).to have_received(:respond)
      end
    end
  end
end
