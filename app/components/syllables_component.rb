# frozen_string_literal: true

class SyllablesComponent < ViewComponent::Base
  attr_reader :syllables

  def initialize(text:)
    @syllables = text.split("-")
  end
end
