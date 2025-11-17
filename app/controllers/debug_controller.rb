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
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Unauthorized" unless current_user&.role == "Admin"
  end

  def set_page_title
    @page_title = "Debug Dashboard"
  end
end
