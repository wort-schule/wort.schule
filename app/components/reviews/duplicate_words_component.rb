# frozen_string_literal: true

class Reviews::DuplicateWordsComponent < ViewComponent::Base
  attr_reader :change_group, :words

  def initialize(change_group:, words:)
    @change_group = change_group
    @words = words
  end
end
