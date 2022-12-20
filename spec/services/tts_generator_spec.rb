# frozen_string_literal: true

require "google/cloud/text_to_speech"
require "google/cloud/text_to_speech/v1"

RSpec.describe TtsGenerator do
  let(:client) { double("client") }

  before do
    allow(::Google::Cloud::TextToSpeech).to receive(:text_to_speech).and_return(client)
    allow(client).to receive(:synthesize_speech).and_return(double("response", audio_content: "audio_content"))
  end

  it "returns a mp3 file as StringIO" do
    io = TtsGenerator.call("Hello world")
    expect(io).to be_a(StringIO)
    expect(io.string).to eq("audio_content")
  end
end
