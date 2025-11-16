# frozen_string_literal: true

class CompoundsController < ApplicationController
  def index
    query = params[:q].to_s.strip
    limit = 50 # Limit results to prevent loading too many records

    # Build collections with search filtering and limit
    @elements = []

    if query.present?
      # Search compound parts by name
      @elements += CompoundPreconfix.where("name ILIKE ?", "%#{query}%").limit(limit)
      @elements += CompoundPostconfix.where("name ILIKE ?", "%#{query}%").limit(limit)
      @elements += CompoundInterfix.where("name ILIKE ?", "%#{query}%").limit(limit)
      @elements += CompoundPhonemreduction.where("name ILIKE ?", "%#{query}%").limit(limit)
      @elements += CompoundVocalalternation.where("name ILIKE ?", "%#{query}%").limit(limit)

      # Search words by name
      @elements += FunctionWord.where("name ILIKE ?", "%#{query}%").limit(limit)
      @elements += Word.ordered_lexigraphically
        .where.not(type: "FunctionWord")
        .where("name ILIKE ?", "%#{query}%")
        .limit(limit)
    else
      # When no query, return a reasonable initial set (first 50 of each type)
      @elements += CompoundPreconfix.order(:name).limit(10)
      @elements += CompoundPostconfix.order(:name).limit(10)
      @elements += CompoundInterfix.order(:name).limit(10)
      @elements += CompoundPhonemreduction.order(:name).limit(10)
      @elements += CompoundVocalalternation.order(:name).limit(10)
      @elements += FunctionWord.order(:name).limit(10)
      @elements += Word.ordered_lexigraphically.where.not(type: "FunctionWord").limit(10)
    end

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
