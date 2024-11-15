# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  REVIEWS_REQUIRED = 2

  included do
    attr_accessor :action

    scope :reviewable, ->(reviewer) {
      reviewer_id = reviewer.id

      where(successor_id: nil)
        .where(
          state: :waiting_for_review,
          attribute_name: reviewer.review_attributes_without_types
        )
        .where(
          id: select(:id)
        .where("NOT EXISTS (SELECT 1 FROM reviewers WHERE reviewers.word_attribute_edit_id = word_attribute_edits.id AND reviewers.reviewer_id = ?)", reviewer_id)
        )
        .order(:created_at)
    }

    belongs_to :successor, optional: true, polymorphic: true

    has_many :reviewers, dependent: nil

    def store_review(reviewer:, state:)
      reviews.create!(
        reviewer:,
        state:
      )

      try_to_finish_review
    end

    def confirmed_review_count
      reviews.where(state: :confirmed).count
    end

    def try_to_finish_review
      return if confirmed_review_count < REVIEWS_REQUIRED

      transaction do
        update!(state: :confirmed)

        word.update!(attribute_name => value)
      end
    end
  end
end
