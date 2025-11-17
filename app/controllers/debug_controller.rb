class DebugController < ApplicationController
  before_action :authorize_admin!
  before_action :set_page_title

  def index
    @llm_service = LlmService.active
    @recent_jobs = GoodJob::Job.order(created_at: :desc).limit(50)
    @pending_jobs = GoodJob::Job.where(finished_at: nil).order(created_at: :desc)
    @failed_jobs = GoodJob::Job.where("error IS NOT NULL").order(finished_at: :desc).limit(20)
    @llm_invocations = WordLlmInvocation.order(created_at: :desc).limit(50)
    @word_imports = WordImport.order(created_at: :desc).limit(20)
    @llm_queue_stats = GoodJob::Job.where(queue_name: "llm").group(:finished_at).count
  rescue => e
    @error = e
    @error_message = e.message
    @error_backtrace = e.backtrace
    Rails.logger.error("Debug Controller Error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end

  # Helper method to extract JSON error from API responses
  helper_method :extract_json_error
  def extract_json_error(error)
    return nil if error.blank?

    # Try to extract JSON from the error message
    json_match = error.match(/(\{.*\})/m)
    if json_match
      begin
        json_data = JSON.parse(json_match[1])
        JSON.pretty_generate(json_data)
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Helper method to get a short error summary
  helper_method :error_summary
  def error_summary(error)
    return "" if error.blank?

    # Get the first line which usually contains the main error
    first_line = error.lines.first&.strip || ""

    # Remove ANSI color codes
    first_line.gsub(/\e\[[0-9;]*m/, "")
  end

  # Helper method to parse word key and return word details
  helper_method :parse_word_key
  def parse_word_key(key)
    # For enrichment keys: "Noun#123" -> {type: "Noun", id: 123, word: <Word>}
    # For check_base_form keys: "Hund#Animals#Noun" -> {name: "Hund", topic: "Animals", type: "Noun"}
    return nil if key.blank?

    parts = key.split("#")
    if parts.size == 2 && parts[1].match?(/^\d+$/)
      # This is a word enrichment key
      word_type = parts[0]
      word_id = parts[1].to_i
      word = word_type.constantize.find_by(id: word_id)
      {type: :word_enrichment, word_type: word_type, word_id: word_id, word: word}
    elsif parts.size == 3
      # This is a check_base_form key
      {type: :check_base_form, name: parts[0], topic: parts[1], word_type: parts[2]}
    end
  rescue
    nil
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Unauthorized" unless current_user&.role == "Admin"
  end

  def set_page_title
    @page_title = "Debug Dashboard"
  end
end
