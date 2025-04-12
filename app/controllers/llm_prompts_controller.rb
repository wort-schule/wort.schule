# frozen_string_literal: true

class LlmPromptsController < ApplicationController
  load_and_authorize_resource

  def index
    @llm_prompts = @llm_prompts.order(:identifier)
  end

  def edit
  end

  def update
    if @llm_prompt.update(llm_prompt_params)
      redirect_to llm_prompts_path
    else
      render :edit
    end
  end

  private

  def llm_prompt_params
    params.require(:llm_prompt).permit(:content)
  end
end
