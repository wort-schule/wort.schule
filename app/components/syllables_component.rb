# frozen_string_literal: true

class SyllablesComponent < ViewComponent::Base
  attr_reader :syllables

  def initialize(text:)
    @syllables = text.split("-")
  end

  def syllable_arc
    @syllable_arc ||= SyllableArc.new(Rails.root.join("app/assets/fonts/#{helpers.current_font}-Regular.ttf"))
  end
end
