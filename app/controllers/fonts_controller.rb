# frozen_string_literal: true

class FontsController < ApplicationController
  authorize_resource class: false

  def show
    @font = Fonts.by_key(params[:font]) || Fonts.default
    @syllable_arc = SyllableArc.new(@font)

    syllables = Word
      .pluck(:syllables)
      .compact_blank
      .map do |word|
        if word.include?("-")
          word.split("-")
        elsif word.include?("|")
          word.split("|")
        elsif word.strip.include?(" ")
          word.split(" ")
        else
          word
        end
      end
      .flatten
      .map(&:downcase)
      .map(&:strip)
      .uniq
      .sort

    @calculations = syllables
      .map { |syllable| [syllable, @syllable_arc.width(syllable)] }
      .sort_by { |_syllable, width| width }
      .uniq { |_syllable, width| width }
  end
end
