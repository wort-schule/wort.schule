# frozen_string_literal: true

RSpec.describe TtsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }
  let(:word) { create(:noun, with_tts: with_tts) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context "when with_tts is false" do
    let(:with_tts) { false }

    it "doesn't generate the audio" do
      expect(TtsGenerator).not_to receive(:call)
      perform_enqueued_jobs { job }
    end
  end

  context "when with_tts is true" do
    let(:with_tts) { true }

    it "doesn't generate the audio" do
      expect(TtsGenerator).to receive(:call).with(word.name).and_return(StringIO.new)
      perform_enqueued_jobs { job }
    end
  end
end
