# frozen_string_literal: true

class RequestImageComponent < ViewComponent::Base
  attr_reader :word, :user

  def initialize(word:, user:)
    @word = word
    @user = user
  end

  def render?
    user.present? && !word.image.attached? && !ImageRequest.exists?(word:, user:)
  end
end
