# frozen_string_literal: true

class SearchesController < PublicController
  include ListAddable
  include WordHelper

  def show
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: params.dig(:filterrific, :filter_type).presence || "")
    ) or return

    @words = @filterrific
      .find
      .ordered_lexigraphically
      .page(params[:page])

    @counts = {
      all: word_count_for(""),
      nouns: word_count_for("Noun"),
      verbs: word_count_for("Verb"),
      adjectives: word_count_for("Adjective"),
      function_words: word_count_for("FunctionWord")
    }

    @is_filter_open = params[:is_filter_open] == "true"
  end

  private

  def background_color
    "bg-white"
  end

  def full_width?
    true
  end
end
