# frozen_string_literal: true

RSpec.describe SpeechkitBot::MessageHandler do
  describe '#respond' do
    subject(:respond) { described_class.new(bot, message).respond }

    let(:bot) { double(api: {}) }
    let(:message) { double(chat: {}) }
    let(:sender) { double }

    before do
      allow(SpeechkitBot::MessageSender).to receive(:new).and_return(sender)
      allow(sender).to receive(:send)
    end

    it 'calls MessageSender with default text' do
      respond
      expect(sender).to have_received(:send)
        .with(/Этот бот распознает речь. Пожалуйста, пришлите аудио сообщение/)
    end

    context 'with voice message' do
      let(:message) { instance_double('Telegram::Bot::Types::Message', chat: {}, voice: {}) }
      let(:voice_handler) { double }

      before do
        allow(Telegram::Bot::Types::Message).to receive(:===).with(message).and_return(true)
        allow(SpeechkitBot::VoiceHandler).to receive(:new).and_return(voice_handler)
        allow(voice_handler).to receive(:call)
      end

      it 'calls VoiceHandler' do
        respond
        expect(SpeechkitBot::VoiceHandler).to have_received(:new).with(bot, message)
        expect(voice_handler).to have_received(:call)
      end
    end
  end
end
