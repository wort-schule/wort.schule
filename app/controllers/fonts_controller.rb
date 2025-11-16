# frozen_string_literal: true

class FontsController < ApplicationController
  authorize_resource class: false

  def show
    @font = Fonts.by_key(params[:font]) || Fonts.default
    @syllable_arc = SyllableArc.new(@font)

    # Optimize syllable processing by combining operations and using a more efficient approach
    syllables = Word
      .where.not(syllables: [nil, ""])
      .pluck(:syllables)
      .flat_map do |word|
        # Split by multiple delimiters in a single pass
        word.split(/[-|\s]+/).map { |s| s.strip.downcase }
      end
      .reject(&:blank?)
      .uniq
      .sort

    @calculations = syllables
      .map { |syllable| [syllable, @syllable_arc.width(syllable)] }
      .sort_by { |_syllable, width| width }
      .uniq { |_syllable, width| width }
  end
end
