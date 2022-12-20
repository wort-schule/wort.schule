# frozen_string_literal: true

# This jobs generates a TTS audio attachments for a given word record with enabled TTS.
class TtsJob < ApplicationJob
  queue_as :default

  def perform(word)
    return true unless word
    return true unless word.with_tts?

    @logger = Logger.new(Rails.root.join("log", "tts.log"))
    @logger.info "Starting TTS job"

    generate_audio word

    @logger.info "Finished TTS job"
  end

  private def generate_audio(word)
    @logger.info "Processing word #{word.id} (#{word.name})"

    word.audio.attach(
      io: TtsGenerator.call(text(word)),
      filename: "audio.mp3",
      content_type: "audio/mp3"
    )
  rescue => e
    @logger.error "Error while processing word: #{e.class.name} #{e.message}"
  end

  private def text(word)
    return word.name unless word.is_a?(Noun)

    "#{word.article_definite} #{word.name}"
  end
end
