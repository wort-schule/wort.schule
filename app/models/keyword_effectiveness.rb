# frozen_string_literal: true

class KeywordEffectiveness < ApplicationRecord
  self.table_name = "keyword_effectiveness"

  # Phoenix/Ecto uses inserted_at instead of Rails' created_at
  def self.timestamp_attributes_for_create
    ["inserted_at"]
  end

  belongs_to :word, optional: true
  belongs_to :keyword, class_name: "Word", foreign_key: :keyword_id, optional: true

  scope :correct, -> { where(led_to_correct: true) }
  scope :incorrect, -> { where(led_to_correct: false) }
  scope :for_word, ->(word_id) { where(word_id: word_id) }
  scope :for_keyword, ->(keyword_id) { where(keyword_id: keyword_id) }

  def time_to_guess_ms
    return nil unless picked_at && revealed_at

    ((picked_at - revealed_at) * 1000).to_i
  end
end
