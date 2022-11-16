# frozen_string_literal: true

class FlashcardsController < ApplicationController
  authorize_resource class: false

  def index
    @lists = student.flashcard_lists
  end

  private

  def student
    Student.find(current_user.id)
  end
end
