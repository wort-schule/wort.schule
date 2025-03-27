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
  end
end
