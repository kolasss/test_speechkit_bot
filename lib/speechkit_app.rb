# frozen_string_literal: true

require 'sinatra/base'
require_relative 'speechkit_bot'

class SpeechkitApp < Sinatra::Application
  get '/' do
    'this is speechkit bot app'
  end

  post '/webhook' do
    header_token = request.env['HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN']
    unless header_token && header_token == SpeechkitBot.config[:webhook_secret]
      return 401 # Unauthorized
    end

    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read

    update = Telegram::Bot::Types::Update.new(data)
    message = update.current_message

    SpeechkitBot.logger.debug "@#{message.from.username}: #{message.text}"
    SpeechkitBot::MessageHandler.new(api, message).respond

    200
  end

  def api
    @api ||= SpeechkitBot.new.telegram_client.api
  end
end
