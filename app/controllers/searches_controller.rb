# frozen_string_literal: true

class SearchesController < PublicController
  include ListAddable

  def show
    @filterrific = initialize_filterrific(
      Word,
      params[:filterrific]
    ) or return

    @words = @filterrific
      .find
      .ordered_lexigraphically
      .page(params[:page])

    @counts = {
      all: @words.total_count,
      nouns: count_for("Noun"),
      verbs: count_for("Verb"),
      adjectives: count_for("Adjective"),
      function_words: count_for("FunctionWord")
    }
  end

  private

  def count_for(word_type)
    initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: word_type)
    ).find.count
  end
end
