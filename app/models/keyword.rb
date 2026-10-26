# frozen_string_literal: true

class Keyword < ApplicationRecord
  belongs_to :word

  # Turns "12,7,12" into [12, 7]. Anything that is not a positive id is dropped,
  # so text a crawler glued onto the URL never reaches a query.
  def self.parse_ids(keyword_ids)
    Array(keyword_ids).flat_map { |ids| ids.to_s.split(",") }.map(&:to_i).select(&:positive?).uniq
  end

  # Number of words that carry every one of the given keywords.
  def self.words_count(keyword_ids)
    ids = parse_ids(keyword_ids)
    return 0 if ids.empty?

    where(keyword_id: ids)
      .group(:word_id)
      .having("COUNT(DISTINCT keyword_id) = ?", ids.size)
      .pluck(:word_id)
      .size
  end
end
