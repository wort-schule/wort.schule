# frozen_string_literal: true

class SyllablesOverviewController < ApplicationController
  authorize_resource class: false

  def index
    @per_page = params[:per_page].present? ? params[:per_page].to_i : 50

    words = Word.ordered_lexigraphically

    if params[:q].present?
      query = Word.replace_regex(params[:q])
      words = words.where("words.name ILIKE ?", "%#{query}%")
    end

    case params[:syllable_filter]
    when "missing_syllables"
      words = words.where(syllables: [nil, ""])
    when "missing_written"
      words = words.where(written_syllables: [nil, ""])
    when "has_both"
      words = words.where.not(syllables: [nil, ""]).where.not(written_syllables: [nil, ""])
    when "mismatch"
      words = words.where.not(syllables: [nil, ""]).where.not(wiktionary_syllables: [nil, ""])
        .where("words.syllables != words.wiktionary_syllables")
    when "not_fetched"
      words = words.where(wiktionary_syllables: [nil, ""])
    when "verified"
      words = words.where(syllables_verified: true)
    when "unverified"
      words = words.where(syllables_verified: false)
    end

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

    word.update!(
      syllables: params[:syllables],
      written_syllables: params[:written_syllables],
      syllables_verified: params[:syllables_verified] == "1"
    )

    redirect_to syllables_overview_index_path(filter_params), notice: t(".success", word: word.name)
  end

  def fetch_all_wiktionary
    words = Word.where(wiktionary_syllables: [nil, ""])
      .where.not(syllables: [nil, ""])

    fetched = 0
    service = WiktionarySyllableService.new
    words.find_each do |word|
      result = service.lookup(word.name)
      if result[:syllables].present?
        word.update_column(:wiktionary_syllables, result[:syllables])
        fetched += 1
      end
      sleep 0.2
    rescue => e
      Rails.logger.warn "Wiktionary fetch failed for #{word.name}: #{e.message}"
    end

    redirect_to syllables_overview_index_path(filter_params),
      notice: t(".fetch_all_success", count: fetched)
  end

  helper_method :filter_params

  private

  def filter_params
    params.permit(:q, :syllable_filter, :per_page, :page)
  end
end
