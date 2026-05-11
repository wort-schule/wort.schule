# frozen_string_literal: true

class BulkEdit < ApplicationRecord
  belongs_to :user

  validates :operation, inclusion: {in: %w[add remove set]}
  validates :field, presence: true
  validates :word_ids, presence: true

  scope :recent_first, -> { order(created_at: :desc) }

  HABTM_FIELDS = %w[topics strategies phenomenons].freeze
  BELONGS_TO_FIELDS = %w[hierarchy_id prefix_id postfix_id].freeze
  BOOLEAN_FIELDS = %w[prototype foreign compound].freeze
  ALL_FIELDS = (HABTM_FIELDS + BELONGS_TO_FIELDS + BOOLEAN_FIELDS).freeze

  def undoable?
    !undone?
  end

  def affected_words_count
    word_ids.size
  end

  def field_label
    case field
    when *HABTM_FIELDS
      field.classify.constantize.model_name.human(count: 2)
    when *BELONGS_TO_FIELDS
      Word.human_attribute_name(field.delete_suffix("_id"))
    else
      Word.human_attribute_name(field)
    end
  end
end
