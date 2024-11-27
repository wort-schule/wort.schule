# frozen_string_literal: true

class ImportWordJob < ApplicationJob
  def perform(word_type:, name:, topic:, word_import_id:)
    Import::Word.new(
      word_type:,
      name:,
      topic:,
      word_import_id:
    ).call
  end
end
