# frozen_string_literal: true

require "google/cloud/text_to_speech"
require "yaml"
require "stringio"

# Generates a TTS mp3 file for a given string via Google Cloud Text to Speech service and returns
# an StringIO object. Configuration in config/tts.yml
#
# Usage:
#   TtsGenerator.call('Hallo Welt')
class TtsGenerator
  def self.call(input)
    new.call input
  end

  def call(input)
    @config = Rails.application.config_for(:tts).symbolize_keys
    generate_mp3 input
  end

  private def generate_mp3(input)
    return if @config[:credentials_file].blank?

    StringIO.new.tap do |io|
      io.write client.synthesize_speech(request_for(input)).audio_content
      io.rewind
    end
  end

  private def client
    ::Google::Cloud::TextToSpeech.text_to_speech do |config|
      config.credentials = @config[:credentials_file]
    end
  end

  private def request_for(input)
    ::Google::Cloud::TextToSpeech::V1::SynthesizeSpeechRequest.new.tap do |request|
      request.input = ::Google::Cloud::TextToSpeech::V1::SynthesisInput.new(text: input)
      request.voice = ::Google::Cloud::TextToSpeech::V1::VoiceSelectionParams.new(
        language_code: "de-DE", name: @config[:voices].sample
      )
      request.audio_config = ::Google::Cloud::TextToSpeech::V1::AudioConfig.new(
        audio_encoding: ::Google::Cloud::TextToSpeech::V1::AudioEncoding::MP3
      )
    end
  end
end
