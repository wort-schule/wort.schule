# frozen_string_literal: true

class LlmPromptsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def edit
  end

  def update
    if @llm_prompt.save
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
