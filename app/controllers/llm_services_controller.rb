# frozen_string_literal: true

class LlmServicesController < ApplicationController
  load_and_authorize_resource

  def index
    @llm_services = @llm_services.order(:name)
  end

  def new
  end

  def create
    if @llm_service.save
      redirect_to llm_services_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @llm_service.update(llm_service_params)
      redirect_to llm_services_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @llm_service.destroy!

    redirect_to llm_services_path
  end

  private

  def page_title
    case action_name
    when "index"
      t("llm_services.index.title")
    when "new"
      t("llm_services.new.title")
    when "edit"
      @llm_service.name
    end
  end
  helper_method :page_title

  def llm_service_params
    params.require(:llm_service).permit(
      :name,
      :service_klass,
      :endpoint,
      :api_key,
      :model
    )
  end
end
