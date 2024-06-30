# frozen_string_literal: true

class KeywordsController < PublicController
  authorize_resource

  def index
    @keywords = Word
      .joins(<<~SQL)
        join (
          select keyword_id, count(word_id)
          from keywords k
          group by keyword_id
        ) keywords on keywords.keyword_id = words.id
      SQL
      .order("keywords.count" => :desc, :name => :asc)
      .page(params[:page])
  end
end
