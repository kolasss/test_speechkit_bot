# frozen_string_literal: true

require 'dry/monads'
require_relative '../message_sender'
require_relative '../speechkit_api'

module SpeechkitBot::Operations
  class RecognitionStatus
    include Dry::Monads[:result, :do]

    def call(voice_task)
      result = yield call_speechkit(voice_task)
      text = format_text(result)
      send_message(voice_task, text)
      update(voice_task, text)
    end

    private

    def call_speechkit(voice_task)
      result = SpeechkitBot::SpeechkitApi.new.recognition_operation_status(voice_task.speechkit_operation_id)
      return Success(result) if result['done']

      Failure(result)
    end

    def format_text(result)
      result.dig('response', 'chunks')&.map do |chunk|
        chunk.dig('alternatives', 0, 'text')
      end&.join(' ')
    end

    def send_message(voice_task, text)
      chat = Telegram::Bot::Types::Chat.new voice_task.message_data[:chat]
      SpeechkitBot::MessageSender.new(chat: chat).send(text, reply_to_message_id: voice_task.message_data[:message_id])
    end

    def update(voice_task, text)
      voice_task.recognition_result = text
      voice_task.status = 'sent_to_user'

      if voice_task.save
        Success(voice_task)
      else
        Failure(voice_task.errors.full_messages)
      end
    end
  end
end
