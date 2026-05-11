# frozen_string_literal: true

class ExampleSentencesOverviewController < ApplicationController
  authorize_resource class: false

  helper_method :llm_available?, :filter_params

  def index
    @per_page = params[:per_page].present? ? params[:per_page].to_i : 50

    words = filtered_words

    @words_total_count = words.count
    @words = if @per_page == 0
      words.all
    else
      words.page(params[:page]).per(@per_page)
    end
  end

  def update
    word = Word.find(params[:id])
    authorize! :update, word

    sentences = Array(params[:example_sentences]).reject(&:blank?)
    word.update!(
      example_sentences: sentences,
      example_sentences_verified: params[:example_sentences_verified] == "1",
      image_alt_text: params[:image_alt_text]
    )

    redirect_to example_sentences_overview_index_path(filter_params),
      notice: t(".success", word: word.name)
  end

  def suggest
    word = Word.find(params[:id])
    authorize! :read, word

    result = Llm::SuggestExampleSentences.new(word: word).call
    render json: result
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def suggest_sentences_batch
    words = filtered_words.where("example_sentences = '[]'::jsonb OR example_sentences IS NULL")
    filled = 0

    words.find_each do |word|
      result = Llm::SuggestExampleSentences.new(word: word).call
      sentences = result["example_sentences"]
      if sentences.is_a?(Array) && sentences.any?
        word.update!(example_sentences: sentences)
        filled += 1
      end
    rescue => e
      Rails.logger.warn "LLM suggest failed for #{word.name}: #{e.message}"
    end

    redirect_to example_sentences_overview_index_path(filter_params),
      notice: t(".suggest_sentences_success", count: filled)
  end

  def suggest_alt_texts_batch
    words = filtered_words
      .joins(:image_attachment)
      .where(image_alt_text: [nil, ""])
    filled = 0

    words.find_each do |word|
      result = Llm::SuggestExampleSentences.new(word: word).call
      alt_text = result["image_alt_text"]
      if alt_text.present?
        word.update!(image_alt_text: alt_text)
        filled += 1
      end
    rescue => e
      Rails.logger.warn "LLM alt-text failed for #{word.name}: #{e.message}"
    end

    redirect_to example_sentences_overview_index_path(filter_params),
      notice: t(".suggest_alt_texts_success", count: filled)
  end

  private

  def llm_available?
    LlmService.active.present? && LlmPrompt.exists?(identifier: "example_sentences")
  end

  def filter_params
    params.permit(:q, :image_filter, :sentence_filter, :per_page, :page)
  end

  def filtered_words
    words = Word.ordered_lexigraphically

    case params[:image_filter]
    when "with_image"
      words = words.joins(:image_attachment)
    when "without_image"
      words = words.where.missing(:image_attachment)
    when "without_alt_text"
      words = words.joins(:image_attachment).where(image_alt_text: [nil, ""])
    when "with_alt_text"
      words = words.joins(:image_attachment).where.not(image_alt_text: [nil, ""])
    end

    if params[:q].present?
      query = Word.replace_regex(params[:q])
      words = words.where("words.name ILIKE ?", "%#{query}%")
    end

    case params[:sentence_filter]
    when "with_sentences"
      words = words.where("jsonb_array_length(example_sentences) > 0")
    when "without_sentences"
      words = words.where("example_sentences = '[]'::jsonb OR example_sentences IS NULL")
    when "verified"
      words = words.where(example_sentences_verified: true)
    when "unverified"
      words = words.where(example_sentences_verified: false)
    end

    words
  end
end
