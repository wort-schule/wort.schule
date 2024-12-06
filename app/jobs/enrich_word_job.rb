# frozen_string_literal: true

class EnrichWordJob < ApplicationJob
  queue_as :llm

  def perform(word_id)
    return if word_id.blank?

    word = Word.find_by(id: word_id)
    return if word.blank?

    Llm::Enrich.new(word:).call
  end
end
