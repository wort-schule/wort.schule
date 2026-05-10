# frozen_string_literal: true

require "test_helper"

class TtsJobTest < ActiveJob::TestCase
  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "when with_tts is false it doesn't generate the audio" do
    word = create(
      :noun,
      with_tts: false,
      example_sentences: ["Not all who wander are lost.", "For even the very wise cannot see all ends."]
    )

    called = false
    TtsService.stub(:call, ->(*) {
      called = true
      StringIO.new
    }) do
      perform_enqueued_jobs { TtsJob.perform_later(word) }
    end

    refute called, "expected TtsService.call NOT to be called"
  end

  test "when with_tts is true it generates the audio" do
    word = create(
      :noun,
      with_tts: true,
      example_sentences: ["Not all who wander are lost.", "For even the very wise cannot see all ends."]
    )

    received_args = []
    TtsService.stub(:call, ->(arg) {
      received_args << arg
      StringIO.new
    }) do
      perform_enqueued_jobs { TtsJob.perform_later(word) }
    end

    assert_includes received_args, "#{word.article_definite} #{word.name}".strip
    assert_includes received_args, word.example_sentences.first
    assert_includes received_args, word.example_sentences.last
  end
end
