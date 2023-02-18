# frozen_string_literal: true

require 'sidekiq'
require_relative '../models/voice_task'
require_relative 'process_voice_task_job'

class NotProcessedVoiceTasksJob
  include Sidekiq::Job

  def perform
    VoiceTask.not_finished.batch_size(100).each do |voice_task|
      ProcessVoiceTaskJob.perform_async(voice_task.id.to_s)
    end
  end
end
