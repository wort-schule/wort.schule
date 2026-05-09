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
