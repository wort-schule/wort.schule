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
    @keyword_ids = (params[:keyword_ids].presence || "").split(",").uniq
    @keywords = Word.where(id: @keyword_ids)
    @all_words = Word.where(
      id: Keyword
      .select(:word_id)
      .where(keyword_id: @keyword_ids)
      .group(:word_id)
      .having("count(word_id) = ?", @keyword_ids.count)
    )
    @related_keywords = Word.where(
      id: Keyword
      .where(word_id: @all_words.select(:id))
      .where.not(keyword_id: @keyword_ids)
      .select(:keyword_id)
    )
      .joins(<<~SQL)
        join (
          select keyword_id, count(word_id)
          from keywords k
          group by keyword_id
        ) keywords on keywords.keyword_id = words.id
      SQL
      .order("keywords.count" => :desc, :name => :asc)
      .page(params[:page])
      .per(12)
    @words = @all_words.page(params[:page])
  end

  private

  def page_title
    case action_name
    when "index"
      t("keywords.index.title")
    when "show"
      @keywords.map(&:name).join(" + ")
    end
  end
  helper_method :page_title
end
