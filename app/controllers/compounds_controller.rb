# frozen_string_literal: true

class CompoundsController < ApplicationController
  def index
    @elements = CompoundPreconfix.all +
      CompoundPostconfix.all +
      CompoundInterfix.all +
      CompoundPhonemreduction.all +
      CompoundVocalalternation.all +
      FunctionWord.all +
      Word.ordered_lexigraphically.where.not(type: "FunctionWord")

    @elements = @elements.map do |element|
      is_word = [Word, Noun, Verb, Adjective, FunctionWord].include?(element.class)

      name = if is_word
        element.meaning.empty? ? element.name : "#{element.name} [#{element.meaning}]"
      else
        "#{element.name} [#{element.model_name.human}]"
      end

      {
        text: name,
        value: "#{is_word ? "Word" : element.class.name}:#{element.id}"
      }
    end

    render json: @elements
  end
end
