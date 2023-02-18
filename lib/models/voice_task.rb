# frozen_string_literal: true

require 'mongoid'
require_relative '../uploaders/voice_message_uploader'

class VoiceTask
  include Mongoid::Document
  include VoiceMessageUploader::Attachment(:voice_message)

  STATUSES = %w[initialized file_saved sent_to_speechkit sent_to_user].freeze

  field :message_data, type: Hash
  field :status, type: String
  field :voice_message_data, type: Hash
  field :speechkit_operation_id, type: String
  field :recognition_result, type: String

  validates :status, presence: true, inclusion: { in: STATUSES }

  index({ status: 1 })

  scope :not_finished, -> { VoiceTask.not(status: 'sent_to_user') }
end
