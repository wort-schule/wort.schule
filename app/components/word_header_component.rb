# frozen_string_literal: true

class WordHeaderComponent < ViewComponent::Base
  renders_one :title
  renders_many :properties

  attr_reader :word

  def initialize(word:)
    @word = word
  end

  def montessori_symbol
    case word.type
    when "Noun" then "montessori/nomen.svg"
    when "Verb" then "montessori/verb.svg"
    when "Adjective" then "montessori/adjektiv.svg"
    when "FunctionWord"
      case word.function_type
      when "article_definite", "article_indefinite" then "montessori/artikel.svg"
      when "auxiliary_verb" then "montessori/hilfsverb.svg"
      when "conjunction" then "montessori/konjunktion.svg"
      when "preposition" then "montessori/praeposition.svg"
      when "pronoun" then "montessori/pronomen.svg"
      end
    end
  end
end
