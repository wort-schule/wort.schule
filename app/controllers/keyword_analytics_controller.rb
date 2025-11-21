# frozen_string_literal: true

class KeywordAnalyticsController < ApplicationController
  authorize_resource :keyword_analytics, class: false

  def index
    @problematic_words = find_problematic_words
    @total_records = KeywordEffectiveness.count
    @overall_success_rate = calculate_overall_success_rate
  end

  def show
    @word = Word.find(params[:id])
    @keyword_stats = fetch_keyword_stats(@word.id)
    @position_stats = fetch_position_stats(@word.id)
    @total_attempts = KeywordEffectiveness.for_word(@word.id).select(:pick_id).distinct.count
    @success_rate = calculate_word_success_rate(@word.id)
  end

  private

  def page_title
    if action_name == "show" && @word
      "Keyword Analytics: #{@word.name}"
    else
      I18n.t("keyword_analytics.index.title")
    end
  end
  helper_method :page_title

  def find_problematic_words
    sql = <<-SQL
      WITH pick_results AS (
        SELECT DISTINCT ON (pick_id)
          word_id,
          pick_id,
          led_to_correct
        FROM keyword_effectiveness
        ORDER BY pick_id, keyword_position DESC
      )
      SELECT
        word_id,
        COUNT(*) as total_attempts,
        SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct_count,
        SUM(CASE WHEN NOT led_to_correct THEN 1 ELSE 0 END) as failures,
        ROUND(SUM(CASE WHEN NOT led_to_correct THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 1) as failure_rate
      FROM pick_results
      GROUP BY word_id
      HAVING COUNT(*) >= 5
      ORDER BY failure_rate DESC
      LIMIT 50
    SQL

    results = ActiveRecord::Base.connection.execute(sql)
    word_ids = results.map { |r| r["word_id"] }
    words = Word.where(id: word_ids).index_by(&:id)

    results.map do |row|
      {
        word: words[row["word_id"]],
        total_attempts: row["total_attempts"],
        correct_count: row["correct_count"],
        failures: row["failures"],
        failure_rate: row["failure_rate"]
      }
    end.compact
  end

  def calculate_overall_success_rate
    total = KeywordEffectiveness.select(:pick_id).distinct.count
    return 0 if total == 0

    correct = KeywordEffectiveness.correct.select(:pick_id).distinct.count
    (correct.to_f / total * 100).round(1)
  end

  def fetch_keyword_stats(word_id)
    stats = KeywordEffectiveness
      .for_word(word_id)
      .group(:keyword_id)
      .having("COUNT(*) >= ?", 1)
      .select(
        :keyword_id,
        "COUNT(*) as shown",
        "SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct",
        "AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time_ms"
      )
      .order("correct DESC")

    keyword_ids = stats.map(&:keyword_id)
    keywords = Word.where(id: keyword_ids).index_by(&:id)

    stats.map do |s|
      {
        keyword: keywords[s.keyword_id],
        shown: s.shown,
        correct: s.correct,
        success_rate: (s.shown > 0) ? (s.correct.to_f / s.shown * 100).round(1) : 0,
        avg_time_ms: s.avg_time_ms&.round(0)
      }
    end
  end

  def fetch_position_stats(word_id)
    KeywordEffectiveness
      .for_word(word_id)
      .group(:keyword_position)
      .select(
        :keyword_position,
        "COUNT(*) as total",
        "SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct",
        "AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time_ms"
      )
      .order(:keyword_position)
      .map do |s|
        {
          position: s.keyword_position,
          total: s.total,
          correct: s.correct,
          success_rate: (s.total > 0) ? (s.correct.to_f / s.total * 100).round(1) : 0,
          avg_time_ms: s.avg_time_ms&.round(0)
        }
      end
  end

  def calculate_word_success_rate(word_id)
    total = KeywordEffectiveness.for_word(word_id).select(:pick_id).distinct.count
    return 0 if total == 0

    correct = KeywordEffectiveness.for_word(word_id).correct.select(:pick_id).distinct.count
    (correct.to_f / total * 100).round(1)
  end
end
