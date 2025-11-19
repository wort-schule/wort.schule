# frozen_string_literal: true

class ImageRequestsController < ApplicationController
  load_and_authorize_resource :image_request, only: :index

  load_and_authorize_resource :word, only: :create
  load_and_authorize_resource :image_request, through: :word, only: :create

  def index
    @requested_word_images = RequestedWordImage.all
  end

  def create
    unless ImageRequest.exists?(word: @word, user: current_user)
      ImageRequest.create!(word: @word, user: current_user)
      flash[:notice] = t(".image_requested")
    end

    redirect_to @word
  end

  private

  def page_title
    t("image_requests.index.title")
  end
  helper_method :page_title
end
