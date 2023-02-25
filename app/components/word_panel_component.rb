# frozen_string_literal: true

class WordPanelComponent < ViewComponent::Base
  include ComponentsHelper

  attr_reader :word

  def initialize(word:)
    @word = word
  end
end
