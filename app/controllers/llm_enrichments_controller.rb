# frozen_string_literal: true

class LlmEnrichmentsController < ApplicationController
  authorize_resource :llm_enrichment, class: false

  def show
  end

  def new
    @llm_enrichment_list = Forms::LlmEnrichmentList.new
  end

  def create
    @llm_enrichment_list = Forms::LlmEnrichmentList.new(
      llm_enrichment_params.merge(user: current_user)
    )

    if @llm_enrichment_list.save
      redirect_to llm_enrichment_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def llm_enrichment_params
    params
      .require(:llm_enrichment)
      .permit(:list_id)
  end
end
