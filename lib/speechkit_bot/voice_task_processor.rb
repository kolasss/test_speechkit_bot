# frozen_string_literal: true

require_relative '../models/voice_task'
require_relative 'operations/process_file'
require_relative 'operations/start_recognition'
require_relative 'operations/recognition_status'

class SpeechkitBot
  class VoiceTaskProcessor
    def call(voice_task_id)
      voice_task = VoiceTask.find(voice_task_id)
      format_result(false, :find_task) unless voice_task

      case voice_task.status
      when 'initialized' then process_file(voice_task)
      when 'file_saved' then call_speechkit(voice_task)
      when 'sent_to_speechkit' then recognition_operation_status(voice_task)
      end
    end

    private

    def process_file(voice_task)
      result = Operations::ProcessFile.new.call(voice_task)
      if result.success?
        call_speechkit(voice_task)
      else
        format_result(true, :process_file)
      end
    end

    def call_speechkit(voice_task)
      Operations::StartRecognition.new.call(voice_task)
      format_result(true, :call_speechkit)
    end

    def recognition_operation_status(voice_task)
      result = Operations::RecognitionStatus.new.call(voice_task)
      if result.success?
        format_result(false, :recognition_status)
      else
        format_result(true, :recognition_status)
      end
    end

    def format_result(need_retry, step)
      {
        need_retry: need_retry,
        step: step
      }
    end
  end
end
