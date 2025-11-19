# frozen_string_literal: true

class FlashcardsController < ApplicationController
  authorize_resource class: false

  def index
    first_list_id = Flashcards::SECTIONS.first
    requested_list_id = params[:list].presence || first_list_id

    @is_first_list = requested_list_id.to_s == first_list_id.to_s

    @list = current_user.flashcard_list(requested_list_id)
    raise ActionController::RoutingError, "Not Found" if @list.blank?
  end

  private

  def page_title
    t("flashcards.index.title")
  end
  helper_method :page_title
end
