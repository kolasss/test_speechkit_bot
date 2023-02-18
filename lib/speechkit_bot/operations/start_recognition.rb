# frozen_string_literal: true

require 'dry/monads'
require_relative '../speechkit_api'

module SpeechkitBot::Operations
  class StartRecognition
    include Dry::Monads[:result, :do]

    def call(voice_task)
      speechkit_operation_id = yield call_speechkit(voice_task)
      save(voice_task, speechkit_operation_id)
    end

    private

    def call_speechkit(voice_task)
      result = SpeechkitBot::SpeechkitApi.new.recognize_async(voice_task.voice_message.url)
      return Success(result['id']) if result['id']

      Failure("Error calling speechkit api: #{result}")
    end

    def save(voice_task, speechkit_operation_id)
      voice_task.speechkit_operation_id = speechkit_operation_id
      voice_task.status = 'sent_to_speechkit'

      if voice_task.save
        Success(voice_task)
      else
        Failure(voice_task.errors.full_messages)
      end
    end
  end
end
