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
    # Get all word IDs associated with this change group
    word_ids = word_attribute_edits.pluck(:word_id).compact.uniq

    # Also check new_word if it exists and has a created_word
    word_ids << new_word.created_word_id if new_word&.created_word_id

    return if word_ids.empty?

    # Find and discard all queued EnrichWordJobs for these words
    word_ids.each do |word_id|
      GoodJob::Job
        .where(job_class: "EnrichWordJob")
        .where("serialized_params->>'job_class' = ?", "EnrichWordJob")
        .where("serialized_params->'arguments' @> ?", "[#{word_id}]")
        .where(finished_at: nil)
        .find_each do |job|
          job.update!(
            finished_at: Time.current,
            error: "Discarded: Associated ChangeGroup was deleted"
          )
      end
    end
  end
end
