# frozen_string_literal: true

class FontsController < ApplicationController
  authorize_resource class: false

  def show
    @font = (params[:font] || Fonts.keys.first).clamped(Fonts.keys, strict: false)
    @syllable_arc = SyllableArc.new(Rails.root.join("app/assets/fonts/#{@font}-Regular.ttf"))

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
