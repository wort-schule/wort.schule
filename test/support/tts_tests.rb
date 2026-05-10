# frozen_string_literal: true

# Replaces the RSpec.shared_examples "TTS".
#
# Usage:
#
#   class NounsTtsTest < ApplicationSystemTestCase
#     extend TtsTests
#     tts_tests_for Noun
#   end
module TtsTests
  def tts_tests_for(klass)
    singular = klass.model_name.singular
    factory = singular.to_sym

    test "displays the audio player when audio is attached to a #{singular}" do
      word = create(factory)
      word.audios.attach(fixture_file_upload("audio.mp3", "audio/mpeg"))

      visit public_send(:"#{singular}_path", word)

      assert_selector "audio"
    end

    test "does not display the audio player when no audio is attached to a #{singular}" do
      word = create(factory)

      visit public_send(:"#{singular}_path", word)

      assert_no_selector "audio"
    end
  end
end
