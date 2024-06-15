# frozen_string_literal: true

class SyllableArc
  attr_reader :font

  def initialize(font_path)
    @font = TTFunk::File.open(font_path)
  end

  def width(syllable)
    syllable.chars.sum do |character|
      character_code = character.unpack1("U*")
      glyph = font.cmap.unicode.first[character_code]

      font
        .horizontal_metrics
        .for(glyph)
        .advance_width
    end
  end

  def arc(syllable)
    syllable_width = width(syllable)
    width_category = Fonts::SYLLABLE_ARCS.keys.find { |range| range.include?(syllable_width) }
    arc_number = Fonts::SYLLABLE_ARCS[width_category]

    "^#{arc_number}" if arc_number.present?
  end
end
