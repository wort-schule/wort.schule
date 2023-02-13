# frozen_string_literal: true

class FlashcardsController < ApplicationController
  authorize_resource class: false

  def index
    @lists = current_user.flashcard_lists
  end
end
