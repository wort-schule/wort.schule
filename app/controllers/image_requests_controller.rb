# frozen_string_literal: true

class ImageRequestsController < ApplicationController
  load_and_authorize_resource :word
  load_and_authorize_resource :image_request, through: :word

  def create
    unless ImageRequest.exists?(word: @word, user: current_user)
      ImageRequest.create!(word: @word, user: current_user)
      flash[:notice] = t(".image_requested")
    end

    redirect_to @word
  end
end
