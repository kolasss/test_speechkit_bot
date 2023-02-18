# frozen_string_literal: true

RSpec.describe 'running ProcessVoiceTaskJob' do
  subject(:perform) do
    Sidekiq::Testing.inline! do
      ProcessVoiceTaskJob.perform_async(voice_task_id)
    end
  rescue ProcessVoiceTaskJob::ExceptionStandartRetry
    # do nothing
  end

  let(:token) { '123token' }
  let(:config) do
    {
      telegram_bot_token: token,
      speechkit_key: 'key2234'
    }
  end
  let(:voice_task_id) { voice_task.id.to_s }
  let(:message_data) do
    {
      'message_id' => 34,
      'from' => {
        'id' => 71_012_308, 'is_bot' => false, 'first_name' => 'test', 'username' => 'test', 'language_code' => 'ru'
      },
      'date' => 1_676_632_956,
      'chat' => {
        'id' => 71_012_308, 'type' => 'private', 'username' => 'test', 'first_name' => 'user_test_name'
      },
      'voice' => {
        'file_id' => 'AwACAgIAAxkBAAMiY-9jfANAiFwY-pQAATBhobGAOrcCAAKHIwACGqWASx8_9conthEcLgQ',
        'file_unique_id' => 'AgADhyMAAhqlgEs',
        'duration' => 1,
        'mime_type' => 'audio/ogg',
        'file_size' => 35_480
      }
    }
  end

  before do
    allow(SpeechkitBot).to receive(:config).and_return(config)
  end

  context 'when voice task status initialized' do
    subject(:run_with_cassette) do
      VCR.use_cassette(
        'voice_task_initialized',
        preserve_exact_body_bytes: true,
        # allow_playback_repeats: true,
        # record: :new_episodes
        match_requests_on: %i[method uri]
      ) do
        perform
      end
    end

    let(:voice_task) do
      VoiceTask.create(status: 'initialized', message_data: message_data)
    end

    before do
      run_with_cassette
    end

    it 'downloads file from telegram' do
      expect(a_request(:get, "https://api.telegram.org/file/bot#{token}/voice/file_10.oga")).to have_been_made
    end

    it 'saves file to storage' do
      expect(voice_task.reload.voice_message&.url).to be_instance_of(String)
    end

    it 'creates async recognition on speechkit' do
      expect(
        a_request(:post, 'https://transcribe.api.cloud.yandex.net/speech/stt/v2/longRunningRecognize')
      ).to have_been_made
    end

    it 'changes status of voice task' do
      expect(voice_task.reload.status).to eq('sent_to_speechkit')
    end
  end

  context 'when voice task status file_saved' do
    subject(:run_with_cassette) do
      VCR.use_cassette(
        'voice_task_file_saved',
        match_requests_on: %i[method uri]
      ) do
        perform
      end
    end

    let(:voice_task) do
      VoiceTask.create(
        status: 'file_saved',
        message_data: message_data,
        voice_message: File.open('spec/fixtures/file_01.oga')
      )
    end

    before do
      run_with_cassette
    end

    it 'creates async recognition on speechkit' do
      expect(
        a_request(:post, 'https://transcribe.api.cloud.yandex.net/speech/stt/v2/longRunningRecognize')
      ).to have_been_made
    end

    it 'changes status of voice task' do
      expect(voice_task.reload.status).to eq('sent_to_speechkit')
      expect(voice_task.speechkit_operation_id).to eq('e03sup6d5h7rq574ht8g')
    end
  end

  context 'when voice task status sent_to_speechkit' do
    let(:voice_task) do
      VoiceTask.create(
        status: 'sent_to_speechkit',
        message_data: message_data,
        speechkit_operation_id: speechkit_operation_id
      )
    end
    let(:speechkit_operation_id) { 'eoiruwe123' }

    before do
      run_with_cassette
    end

    context 'with recognition operation done' do
      subject(:run_with_cassette) do
        VCR.use_cassette('voice_task_sent_to_speechkit_done') do
          perform
        end
      end

      it 'gets status of operation' do
        expect(
          a_request(:get, "https://operation.api.cloud.yandex.net/operations/#{speechkit_operation_id}")
        ).to have_been_made
      end

      it 'sends message to chat' do
        expect(a_request(
          :post,
          "https://api.telegram.org/bot#{token}/sendMessage"
        ).with(body: /212-85-06/)).to have_been_made
      end

      it 'changes status of voice task' do
        expect(voice_task.reload.status).to eq('sent_to_user')
      end
    end

    context 'with recognition operation is not done' do
      subject(:run_with_cassette) do
        VCR.use_cassette('voice_task_sent_to_speechkit_not_done') do
          perform
        end
      rescue ProcessVoiceTaskJob::ExceptionRecognitionStatusRetry
        # do nothing
      end

      it 'gets status of operation' do
        expect(
          a_request(:get, "https://operation.api.cloud.yandex.net/operations/#{speechkit_operation_id}")
        ).to have_been_made
      end

      it 'doesn\'t send message to chat' do
        expect(a_request(
                 :post,
                 "https://api.telegram.org/bot#{token}/sendMessage"
               )).not_to have_been_made
      end

      it 'doesn\'t change status of voice task' do
        expect(voice_task.reload.status).to eq('sent_to_speechkit')
      end
    end

    context 'with out rescue' do
      subject(:run_with_cassette) { nil }
      subject(:run_with_cassette_wo_rescue) do
        VCR.use_cassette('voice_task_sent_to_speechkit_not_done') do
          Sidekiq::Testing.inline! do
            ProcessVoiceTaskJob.perform_async(voice_task_id)
          end
        end
      end

      it 'raises error' do
        expect { run_with_cassette_wo_rescue }.to raise_error(ProcessVoiceTaskJob::ExceptionRecognitionStatusRetry)
      end
    end
  end
end
