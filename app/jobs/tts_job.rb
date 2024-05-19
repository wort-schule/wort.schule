# frozen_string_literal: true

# This jobs generates a TTS audio attachments for a given word record with enabled TTS.
class TtsJob < ApplicationJob
  queue_as :default

  def perform(word)
    return true unless word
    return true unless word.with_tts?

    @logger = Logger.new(Rails.root.join("log", "tts.log"))
    @logger.info "Starting TTS job"

    generate_audios word

    @logger.info "Finished TTS job"
  end

  private def generate_audios(word)
    word.audios.purge

    attach word, text(word), "audio.mp3"

    word.example_sentences&.each do |sentence|
      attach word, sentence, "#{word.slug_for_example_sentence(sentence)}.mp3"
    end
  end

  private def attach(word, content, name)
    @logger.info "Processing audio #{name} (#{content}) to Word ##{word.id}"

    word.audios.attach(
      io: TtsGenerator.call(content),
      filename: name,
      content_type: "audio/mp3"
    )
  rescue => e
    @logger.error "Error while processing word: #{e.class.name} #{e.message}"
  end

  private def text(word)
    return word.name unless word.is_a?(Noun)

    "#{word.article_definite} #{word.name}".strip
  end
end
