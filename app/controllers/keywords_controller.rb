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

  def show
    @keyword = Word.friendly.find(params[:id])
    @all_words = Word.where(id: Keyword.where(keyword_id: @keyword.id).pluck(:word_id))
    @related_keywords = Word.where(id: Keyword.where(keyword_id: @all_words.pluck(:id)).pluck(:keyword_id)).page(params[:page])
    @words = @all_words.page(params[:page])
  end
end
