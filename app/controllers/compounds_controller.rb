# frozen_string_literal: true

class CompoundsController < ApplicationController
  def index
    @elements = CompoundPreconfix.all +
      CompoundPostconfix.all +
      CompoundInterfix.all +
      CompoundPhonemreduction.all +
      CompoundVocalalternation.all +
      FunctionWord.all.map { |w| w.acting_as } +
      Word.ordered_lexigraphically.where.not(actable_type: "FunctionWord")

    @elements = @elements.map do |element|
      name = if element.class != Word
        "#{element.name} [#{element.model_name.human}]"
      else
        element.meaning.empty? ? element.name : "#{element.name} [#{element.meaning}]"
      end

      {
        text: name,
        value: "#{element.class.name}:#{element.id}"
      }
    end

    render json: @elements
  end
end
