# frozen_string_literal: true

RSpec.describe SpeechkitBot do
  describe '.logger' do
    it 'writes to stdout' do
      expect { described_class.logger.info('Wow! Error!') }
        .to output(/Wow! Error!/).to_stdout_from_any_process
    end
  end

  describe '.config' do
    subject(:config) { described_class.config }

    it 'loads from yml' do
      expect(config).to be_a Hash
    end

    it 'has data' do
      expect(config[:telegram_bot_token]).not_to be_nil
      expect(config[:speechkit_key]).not_to be_nil
    end
  end

  describe '#run' do
    subject(:run) { described_class.new.run }

    let(:bot) { double }

    before do
      allow(Telegram::Bot::Client).to receive(:new).and_return(bot)
      allow(bot).to receive(:listen)
    end

    it 'calls telegram client' do
      run
      expect(bot).to have_received(:listen)
    end

    it 'enqueues job' do
      expect { run }.to change(NotProcessedVoiceTasksJob.jobs, :size).by(1)
    end
  end

  describe '#telegram_client' do
    subject(:telegram_client) { described_class.new.telegram_client }

    let(:bot) { double }

    before do
      allow(Telegram::Bot::Client).to receive(:new).and_return(bot)
    end

    it 'returns bot' do
      expect(telegram_client).to eq(bot)
    end
  end
end
