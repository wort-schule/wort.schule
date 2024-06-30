# frozen_string_literal: true

class WordPanelComponent < ViewComponent::Base
  include ComponentsHelper

  renders_one :name
  renders_one :description

  attr_reader :word, :url, :menu

  def initialize(word:, url: word, menu: false)
    @word = word
    @url = url
    @menu = menu
  end
end
