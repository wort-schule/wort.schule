# frozen_string_literal: true

# This jobs generates TTS audio attachments for all words with enabled TTS but without audio attachment.
# It iterates automatically through all words and ends, when there are no more words to process.
# There should be a cronjob running this job every 5 minutes and avoid duplicates, to make sure, that the jobs
# is always running.
class PrepareJob < ApplicationJob
  queue_as :default

  # There is a rate limit for the TTS API. We shouldn't hit that limit even without pause, but to be
  # absolute sure, we wait a second after each request.
  PAUSE = 1.second


  def perform
    @logger = Logger.new(Rails.root.join('log', 'tts.log'))
    @logger.info 'Starting TTS job'

    loop do
      word = find_next_word

      unless word
        @logger.info 'Found no more words to process. Exiting.'
        return true
      end

      generate_audio word
      sleep PAUSE
    end
  end


  private def generate_audio(word)
    @logger.info "Processing word #{word.id} (#{word.name})"

    word.audio.attach(
      io: TtsGenerator.call(word.name),
      filename: 'audio.mp3',
      content_type: 'audio/mp3'
    )
  end


  private def find_next_word
    Word
      .left_joins(:audio_attachment)
      .group(:id)
      .having('COUNT(active_storage_attachments) = 0')
      .where(with_tts: true)
      .first
  end
end
