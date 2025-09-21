# frozen_string_literal: true

class WordAudioService
  attr_reader :word

  def initialize(word)
    @word = word
  end

  def handle_audio_attachments
    return true unless audio_update_needed?

    if word.with_tts?
      TtsJob.perform_later word
    else
      word.audios&.purge
    end
  end

  def audio_for_word
    word.audios.find { |a| a.filename == "audio.mp3" }
  end

  def audio_for_example_sentence(sentence)
    slug = slug_for_example_sentence(sentence)
    word.audios.find { |a| a.filename == "#{slug}.mp3" }
  end

  def slug_for_example_sentence(sentence)
    Digest::SHA256.hexdigest(sentence).first(6)
  end

  private

  def audio_update_needed?
    word.saved_change_to_with_tts? ||
      word.saved_change_to_example_sentences? ||
      word.saved_change_to_name? ||
      (word.respond_to?(:saved_change_to_genus_id?) && word.saved_change_to_genus_id?)
  end
end
