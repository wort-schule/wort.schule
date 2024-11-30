# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  REVIEWS_REQUIRED = 2

  included do
    attr_accessor :action

    scope :reviewable, ->(reviewer) {
      reviewer_id = reviewer.id

      where(successor_id: nil)
        .where(state: :waiting_for_review)
        .left_joins(:new_word)
        .left_joins(:word_attribute_edits)
        .where(
          "new_words.id IS NOT NULL OR word_attribute_edits.id IN (?)", WordAttributeEdit.where(attribute_name: reviewer.review_attributes_without_types).select(:id)
        )
        .where(
          id: select(:id)
        .where("NOT EXISTS (SELECT 1 FROM reviewers WHERE reviewers.change_group_id = change_groups.id AND reviewers.reviewer_id = ?)", reviewer_id)
        )
        .order(:created_at)
    }

    belongs_to :successor, optional: true, class_name: "ChangeGroup"

    has_many :reviews, dependent: :destroy, inverse_of: :reviewable
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

        word_attribute_edits.each do |word_attribute_edit|
          Llm::Attributes.update!(
            word: word_attribute_edit.word,
            attribute_name: word_attribute_edit.attribute_name,
            value: JSON.parse(word_attribute_edit.value)
          )
        end
      end
    end
  end
end
