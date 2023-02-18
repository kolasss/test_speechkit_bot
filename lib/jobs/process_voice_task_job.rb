# frozen_string_literal: true

require 'sidekiq'
require_relative '../speechkit_bot/voice_task_processor'

class ProcessVoiceTaskJob
  include Sidekiq::Job

  # HINT: для проверки статуса операции распознования время ожидания фиксировано
  sidekiq_retry_in do |count, exception|
    case exception
    when ExceptionRecognitionStatusRetry
      30
    else
      (count**4) + 15
    end
  end

  def perform(voice_task_id)
    result = SpeechkitBot::VoiceTaskProcessor.new.call(voice_task_id)

    return unless result[:need_retry]

    raise ExceptionRecognitionStatusRetry if result[:step] == :recognition_status

    raise ExceptionStandartRetry
  end

  class ExceptionStandartRetry < StandardError; end
  class ExceptionRecognitionStatusRetry < StandardError; end
end
