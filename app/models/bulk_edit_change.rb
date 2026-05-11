# frozen_string_literal: true

class BulkEditChange < ApplicationRecord
  belongs_to :bulk_edit, inverse_of: :word_changes
  belongs_to :word, optional: true

  scope :pending, -> { where(reverted_at: nil) }
  scope :reverted, -> { where.not(reverted_at: nil) }

  def reverted? = reverted_at.present?
end
