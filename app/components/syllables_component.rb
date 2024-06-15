# frozen_string_literal: true

class SyllablesComponent < ViewComponent::Base
  attr_reader :syllables

  def initialize(text:)
    @syllables = parse_syllables(text)
  end

  def syllables_with_arcs
    syllables.map do |syllable|
      arc = syllable_arc.arc(syllable)

      "#{arc}#{syllable}"
    end
  end

  private

  def syllable_arc
    @syllable_arc ||= SyllableArc.new(Rails.root.join("app/assets/fonts/#{helpers.current_font}-Regular.ttf"))
  end

  def parse_syllables(text)
    if text.include?("-")
      text.split("-")
    elsif text.include?("|")
      text.split("|")
    elsif text.strip.include?(" ")
      text.split(" ")
    else
      [text]
    end
  end
end
