# frozen_string_literal: true

require_relative 'message_sender'
require_relative 'voice_task_processor'
require_relative '../models/voice_task'

class SpeechkitBot
  class VoiceHandler
    attr_reader :message, :bot

    def initialize(bot, message)
      @bot = bot
      @message = message
    end

    VOICE_RECEIVED_MESSAGE_TEXT = 'Голосовое сообщение получено, распознование запущено...'

    def call
      raise Error, 'Not a voice message' unless message.voice

      voice_task = save_data(message)
      send_message(VOICE_RECEIVED_MESSAGE_TEXT)
      enqueue_job(voice_task)
    rescue Error => e
      SpeechkitBot.logger.error(e.message)
      send_message(e.message) # TODO: поменять на сообщение об ошибке для юзера
    end

    private

    def save_data(message)
      voice_task = VoiceTask.create(message_data: message.to_h, status: :initialized)
      return voice_task if voice_task.persisted?

      raise Error, voice_task.errors.full_messages
    end

    def enqueue_job(voice_task)
      # здесь будет создание джобы

      VoiceTaskProcessor.new.call(voice_task.id)
    end

    def send_message(text)
      MessageSender.new(api: bot.api, chat: message.chat).send(text)
    end
  end
end
