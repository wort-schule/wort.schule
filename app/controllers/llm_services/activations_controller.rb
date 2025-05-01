# frozen_string_literal: true

module LlmServices
  class ActivationsController < ApplicationController
    load_and_authorize_resource :llm_service

    def create
      ActiveRecord::Base.transaction do
        LlmService.update_all(active: false)
        @llm_service.update!(active: true)
      end

      redirect_to llm_services_path
    end
  end
end
