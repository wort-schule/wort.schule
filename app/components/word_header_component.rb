# frozen_string_literal: true

class WordHeaderComponent < ViewComponent::Base
  renders_one :title
  renders_many :properties

  attr_reader :word, :word_font

  def initialize(word:, word_font:)
    @word = word
    @word_font = word_font
  end

  # Description of the word illustration for screen readers (WCAG 1.1.1).
  # Until an editor has written one, fall back to a generic text: it announces
  # that an image is there without claiming a description we do not have.
  def image_alt_text
    word.image_alt_text.presence || t(".image_fallback_alt", name: word.name)
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
