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
      allow(Telegram::Bot::Client).to receive(:run).and_yield(bot)
      allow(bot).to receive(:listen)
    end

    it 'calls telegram client' do
      run
      expect(Telegram::Bot::Client).to have_received(:run)
      expect(bot).to have_received(:listen)
    end
  end
end
