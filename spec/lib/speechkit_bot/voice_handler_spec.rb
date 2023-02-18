# frozen_string_literal: true

RSpec.describe SpeechkitBot::VoiceHandler do
  describe '#call' do
    subject(:call) { described_class.new(bot, message).call }

    let(:bot) { double(api: {}) }
    let(:sender) { double }

    before do
      allow(SpeechkitBot::MessageSender).to receive(:new).and_return(sender)
      allow(sender).to receive(:send)
    end

    context 'with voice message' do
      let(:message) do
        instance_double('Telegram::Bot::Types::Message', chat: {}, voice: {}, to_h: {})
      end

      it 'creates VoiceTask' do
        expect { call }.to change(VoiceTask, :count).by(1)
      end

      it 'sends message' do
        call
        expect(sender).to have_received(:send)
          .with(/распознование запущено/)
      end

      it 'enqueues job' do
        expect { call }.to change(ProcessVoiceTaskJob.jobs, :size).by(1)
      end
    end
  end
end
