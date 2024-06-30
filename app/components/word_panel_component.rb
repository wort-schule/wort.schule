# frozen_string_literal: true

class WordPanelComponent < ViewComponent::Base
  include ComponentsHelper

  renders_one :name
  renders_one :description

  attr_reader :word, :menu

  def initialize(word:, menu: false)
    @word = word
    @menu = menu
  end
end
