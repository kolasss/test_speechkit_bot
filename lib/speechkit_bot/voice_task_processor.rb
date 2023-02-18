# frozen_string_literal: true

require_relative 'message_sender'
require_relative '../models/voice_task'
require_relative 'operations/process_file'
require_relative 'operations/start_recognition'
require_relative 'operations/recognition_status'

class SpeechkitBot
  class VoiceTaskProcessor
    # attr_reader :voice_task_id

    # def initialize(voice_task_id)
    #   @voice_task_id = voice_task_id
    # end

    def call(voice_task_id)
      voice_task = load_voice_task(voice_task_id)

      case voice_task.status
      when 'initialized' then process_file(voice_task)
      when 'file_saved' then call_speechkit(voice_task)
      when 'sent_to_speechkit' then recognition_operation_status(voice_task)
      end

      # raise 'not implemented' # temp
      # rescue Error => e
      #   SpeechkitBot.logger.error(e.message)
      #   send_message(e.message)
    end

    private

    def load_voice_task(id)
      voice_task = VoiceTask.find(id)
      raise Error, "voice_task not found, id: #{voice_task_id}" unless voice_task

      voice_task
    end

    def process_file(voice_task)
      result = Operations::ProcessFile.new.call(voice_task)
      call_speechkit(voice_task) if result.success?
    end

    def call_speechkit(voice_task)
      Operations::StartRecognition.new.call(voice_task)
    end

    def recognition_operation_status(voice_task)
      result = Operations::RecognitionStatus.new.call(voice_task)
      return if result.failure?

      voice_task.update_attributes
    end

    # def send_message(text)
    #   MessageSender.new(chat: message.chat).send(text)
    # end
  end
end
