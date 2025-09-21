# frozen_string_literal: true

class SearchesController < PublicController
  include ListAddable
  include WordHelper

  def show
    @filter_type = params.dig(:filterrific, :filter_type).presence || ""
    @mode = FilterMode.new(mode: params[:mode])
    @filterrific = initialize_filterrific(
      Word,
      (filter_params || {}).merge(filter_type: @filter_type)
    ) or return

    @all_words = @filterrific
      .find
      .ordered_lexigraphically

    @words = @all_words
      .page(params[:page])

    @counts = {
      all: word_count_for(""),
      nouns: word_count_for("Noun"),
      verbs: word_count_for("Verb"),
      adjectives: word_count_for("Adjective"),
      function_words: word_count_for("FunctionWord")
    }
  end

  private

  def background_color
    "bg-white"
  end

  def full_width?
    true
  end

  def filter_params
    filterrific_params = params.fetch(:filterrific, {}).permit!

    # Handle filters with nested parameters (conjunction + array of values)
    allowed_params = {}
    filterrific_params.each do |key, value|
      if permitted_filters.map(&:to_s).include?(key)
        # Handle both simple values and nested hashes for filters with conjunction
        allowed_params[key] = value
      end
    end

    params[:filterrific] = allowed_params
    allowed_params
  end

  def permitted_filters
    always_permitted = %i[filter_type filter_home filter_syllables_empty]
    advanced_filters = %i[
      filter_wordstarts
      filter_wordends
      filter_wordcontains
      filter_topic
      filter_hierarchy
      filter_keywords
      filter_letter_count
      filter_syllables_count
    ]
    power_filters = %i[
      filter_letters
      filter_source
      filter_consonant_vowel
      filter_phenomenons
      filter_strategies
      filter_foreign
      filter_modal
      filter_compound
      filter_example_sentences
      filter_singularetantum
      filter_pluraletantum
      filter_prototype
      filter_subjectless
      filter_perfect_haben
      filter_perfect_sein
      filter_strong
      filter_irregular_declination
      filter_absolute
      filter_irregular_comparison
      filter_images
    ]

    case @mode.mode
    when :omni
      always_permitted
    when :advanced
      always_permitted + advanced_filters
    when :power
      always_permitted + advanced_filters + power_filters
    end
  end
end
