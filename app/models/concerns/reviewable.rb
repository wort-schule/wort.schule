# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  included do
    attr_accessor :action

    # Change groups still open for this reviewer: not superseded, waiting for
    # review, and not already reviewed by them. Shared by the reviewable scope
    # and ChangeGroup.reviewable_type_counts so "what counts as pending work"
    # lives in one place. The id-in-subquery form lets the reviewable scope add
    # its left joins without the NOT EXISTS clause interacting with them.
    scope :pending_for_reviewer, ->(reviewer) {
      where(successor_id: nil)
        .where(state: :waiting_for_review)
        .where(
          id: select(:id)
            .where("NOT EXISTS (SELECT 1 FROM reviewers WHERE reviewers.change_group_id = change_groups.id AND reviewers.reviewer_id = ?)", reviewer.id)
        )
    }

    scope :reviewable, ->(reviewer) {
      matching_edit_ids = WordAttributeEdit.where(attribute_name: reviewer.review_attributes_without_types).select(:id)

      # New words are an opt-out review type: they only show up while the
      # reviewer keeps them enabled (see User#review_new_words).
      type_condition = if reviewer.review_new_words?
        ["new_words.id IS NOT NULL OR word_attribute_edits.id IN (?)", matching_edit_ids]
      else
        ["word_attribute_edits.id IN (?)", matching_edit_ids]
      end

      # The type filter joins word_attribute_edits, so a change group with
      # several matching edits would fan out into duplicate rows. Collect the
      # matching ids in a subquery and select change groups by id so each
      # appears exactly once (and the outer ORDER BY needs no DISTINCT).
      matching = pending_for_reviewer(reviewer)
        .left_joins(:new_word)
        .left_joins(:word_attribute_edits)
        .where(*type_condition)

      where(id: matching.select(:id)).order(:created_at)
    }

    belongs_to :successor, optional: true, class_name: "ChangeGroup"
    has_many :predecessors, class_name: "ChangeGroup", foreign_key: :successor_id, inverse_of: :successor, dependent: :destroy

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
      required_reviews = GlobalSetting.reviews_required
      return if confirmed_review_count < required_reviews

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
