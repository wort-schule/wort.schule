# frozen_string_literal: true

RSpec.describe TtsGenerator do
  it "returns a mp3 file as StringIO" do
    io = TtsGenerator.call("Hello world")
    expect(io).to be_a(StringIO)
  end
end
