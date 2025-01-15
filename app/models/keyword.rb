# frozen_string_literal: true

class Keyword < ApplicationRecord
  belongs_to :word

  def self.words_count(keyword_ids)
    result = connection.execute <<~SQL
      SELECT DISTINCT COUNT(*)
      FROM (
        SELECT word_id, array_agg(keyword_id) AS keyword_ids FROM keywords k GROUP BY word_id
      ) keywords
      WHERE ARRAY[#{keyword_ids.join(",")}] <@ keywords.keyword_ids
    SQL

    result.getvalue(0, 0)
  end
end
