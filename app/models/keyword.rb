# frozen_string_literal: true

class Keyword < ApplicationRecord
  belongs_to :word

  def self.words_count(keyword_id)
    Keyword
      .select(:keyword_id)
      .where(keyword_id: keyword_id)
      .group(:keyword_id)
      .count
      .values
      .first
  end
end
