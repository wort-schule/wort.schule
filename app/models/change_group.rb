# frozen_string_literal: true

class ChangeGroup < ApplicationRecord
  extend Enumerize
  include Reviewable

  enumerize :state, in: %i[waiting_for_review edited confirmed invalid created duplicate discarded], default: :waiting_for_review

  before_destroy :cancel_related_enrich_word_jobs

  has_many :word_attribute_edits,
    -> { in_order_of(:attribute_name, Llm::Enrich::ATTRIBUTE_GROUPS.flatten.map(&:to_s), filter: false) },
    dependent: :destroy
  has_one :new_word, dependent: :destroy

  accepts_nested_attributes_for :word_attribute_edits, :new_word

  # Pending review counts per type ("new_word" plus each attribute_name),
  # independent of the reviewer's current selection. The filter uses these to
  # show how much work waits per type and which types can be toggled on or off.
  def self.reviewable_type_counts(reviewer)
    base = pending_for_reviewer(reviewer)

    counts = base
      .joins(:word_attribute_edits)
      .group("word_attribute_edits.attribute_name")
      .distinct
      .count("change_groups.id")

    new_word_count = base.joins(:new_word).count
    counts["new_word"] = new_word_count if new_word_count.positive?

    counts
  end

  # Counts of this change group's reviews by outcome, for the pending-review
  # index badges: confirmed, skipped, and everything else.
  def review_state_counts
    confirmed = reviews.count { |review| review.state == "confirmed" }
    skipped = reviews.count { |review| review.state == "skipped" }

    {
      confirmed: confirmed,
      skipped: skipped,
      other: reviews.size - confirmed - skipped
    }
  end

  private

  def cancel_related_enrich_word_jobs
    word_ids = word_attribute_edits.pluck(:word_id).compact
    word_ids << new_word.created_word_id if new_word&.created_word_id
    word_ids.uniq!

    return if word_ids.blank?

    or_clauses = (["serialized_params->'arguments' @> ?::jsonb"] * word_ids.size).join(" OR ")
    bindings = word_ids.map { |id| "[#{id}]" }

    GoodJob::Job
      .where(job_class: "EnrichWordJob", finished_at: nil)
      .where(or_clauses, *bindings)
      .update_all(
        finished_at: Time.current,
        error: "Discarded: Associated ChangeGroup was deleted"
      )
  end
end
