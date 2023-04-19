# frozen_string_literal: true

class WordPanelComponent < ViewComponent::Base
  include ComponentsHelper

  attr_reader :word, :menu

  def initialize(word:, menu: false)
    @word = word
    @menu = menu
  end
end
