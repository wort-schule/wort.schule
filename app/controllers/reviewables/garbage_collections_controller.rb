# frozen_string_literal: true

module Reviewables
  class GarbageCollectionsController < ApplicationController
    authorize_resource :review, class: false

    def show
    end

    def new
    end

    def create
      Reviews::DeleteOpenJob.perform_later

      redirect_to reviewables_garbage_collection_path
    end

    private

    def page_title
      case action_name
      when "new"
        t("reviewables.garbage_collections.new.title")
      when "show"
        t("reviewables.garbage_collections.show.title")
      end
    end
    helper_method :page_title
  end
end
