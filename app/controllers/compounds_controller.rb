# frozen_string_literal: true

class CompoundsController < ApplicationController
  def index
    query = params[:q].to_s.strip
    limit = 50 # Limit results to prevent loading too many records

    # Define model classes for compound parts
    compound_classes = [
      CompoundPreconfix, CompoundPostconfix, CompoundInterfix,
      CompoundPhonemReduction, CompoundVocalalternation
    ]

    # Use a Set for faster word class lookup
    word_class_set = Set.new([Word, Noun, Verb, Adjective, FunctionWord])

    # Build collections with search filtering and limit
    @elements = []

    if query.present?
      # Search compound parts by name - combine queries for better performance
      compound_classes.each do |klass|
        @elements.concat(klass.where("name ILIKE ?", "%#{query}%").limit(limit).to_a)
      end

      # Search words by name
      @elements.concat(FunctionWord.where("name ILIKE ?", "%#{query}%").limit(limit).to_a)
      @elements.concat(
        Word.ordered_lexigraphically
          .where.not(type: "FunctionWord")
          .where("name ILIKE ?", "%#{query}%")
          .limit(limit)
          .to_a
      )
    else
      # When no query, return a reasonable initial set (first 10 of each type)
      compound_classes.each do |klass|
        @elements.concat(klass.order(:name).limit(10).to_a)
      end
      @elements.concat(FunctionWord.order(:name).limit(10).to_a)
      @elements.concat(Word.ordered_lexigraphically.where.not(type: "FunctionWord").limit(10).to_a)
    end

    # Map elements to JSON format using Set for faster lookup
    @elements = @elements.map do |element|
      is_word = word_class_set.include?(element.class)

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
