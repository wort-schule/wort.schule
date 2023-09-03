# frozen_string_literal: true

class SearchesController < PublicController
  include ListAddable
  include WordHelper

  def show
    @filter_type = params.dig(:filterrific, :filter_type).presence || ""
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: @filter_type)
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

    @mode = FilterMode.new(mode: params[:mode])
  end

  private

  def background_color
    "bg-white"
  end

  def full_width?
    true
  end
end
