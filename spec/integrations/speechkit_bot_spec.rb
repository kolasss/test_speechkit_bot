# frozen_string_literal: true

RSpec.describe 'running bot' do
  subject(:run) do
    thread = Thread.new do
      SpeechkitBot.new.run
    end
    sleep(0.3)
    thread.kill
  end

  let(:token) { '123token' }
  let(:config) do
    {
      telegram_bot_token: token,
      speechkit_key: 'key2234'
    }
  end

  before do
    allow(SpeechkitBot).to receive(:config).and_return(config)
  end

  context 'with no updates' do
    let(:get_updates_response_body) do
      '{"ok":true,"result":[]}'
    end

    before do
      stub_request(:post, "https://api.telegram.org/bot#{token}/getUpdates")
        .to_return(body: get_updates_response_body)
    end

    it 'get updates' do
      run
      expect(a_request(:post, "https://api.telegram.org/bot#{token}/getUpdates")).to have_been_made.at_least_once
    end
  end

  context 'with text message' do
    it 'sends message to chat' do
      VCR.use_cassette 'with_text_message', allow_playback_repeats: true do
        run
      end

      expect(a_request(
        :post,
        "https://api.telegram.org/bot#{token}/sendMessage"
      ).with(body: /chat_id=71043908&text=/)).to have_been_made
      expect(a_request(
        :post,
        "https://api.telegram.org/bot#{token}/getUpdates"
      ).with(body: 'offset=61510802&timeout=20')).to have_been_made.at_least_once
    end
  end

  context 'with voice message' do
    subject(:run_with_cassette) do
      VCR.use_cassette(
        'with_voice_message',
        # preserve_exact_body_bytes: true,
        allow_playback_repeats: true,
        record: :new_episodes
      ) do
        run
      end
    end

    it 'creates VoiceTask' do
      expect { run_with_cassette }.to change(VoiceTask, :count).by(1)
    end

    it 'enqueues job' do
      expect { run_with_cassette }.to change(ProcessVoiceTaskJob.jobs, :size).by(1)
    end

    it 'sends message to chat' do
      run_with_cassette
      expect(a_request(
        :post,
        "https://api.telegram.org/bot#{token}/sendMessage"
      ).with(body: /chat_id=71043908&text=/)).to have_been_made
    end
  end
end
