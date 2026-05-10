# frozen_string_literal: true

require "test_helper"
require "google/cloud/text_to_speech"
require "google/cloud/text_to_speech/v1"

class TtsServiceTest < ActiveSupport::TestCase
  test "returns a mp3 file as StringIO" do
    response = Object.new
    response.define_singleton_method(:audio_content) { "audio_content" }

    client = Object.new
    client.define_singleton_method(:synthesize_speech) { |*| response }

    ::Google::Cloud::TextToSpeech.stub(:text_to_speech, ->(*) { client }) do
      io = TtsService.call("Hello world")
      assert_kind_of StringIO, io
      assert_equal "audio_content", io.string
    end
  end
end
