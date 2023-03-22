# frozen_string_literal: true

class WordHeaderComponent < ViewComponent::Base
  renders_one :title
  renders_many :properties

  attr_reader :word

  def initialize(word:)
    @word = word
  end
end
