# frozen_string_literal: true

class SyllablesComponent < ViewComponent::Base
  attr_reader :syllables, :word_view_setting

  def initialize(text:, word_view_setting:)
    @syllables = parse_syllables(text)
    @word_view_setting = word_view_setting
  end

  def syllables_with_arcs
    syllables.map do |syllable|
      arc = syllable_arc.arc(syllable)

      "#{arc}#{syllable}"
    end
  end

  def render?
    syllables.compact_blank.present?
  end

  private

  def syllable_arc
    @syllable_arc ||= SyllableArc.new(helpers.current_font)
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
