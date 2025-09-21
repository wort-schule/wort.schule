# frozen_string_literal: true

class PhoneticsService
  VOWELS = "aeiouäöü"

  attr_reader :word

  def initialize(word)
    @word = word
  end

  def set_consonant_vowel_pattern
    letters.join
      .gsub(/[#{VOWELS}]/o, "V")
      .gsub(/[^V]/, "K")
  end

  def update_cologne_phonetics
    cologne_phonetics_terms.filter_map do |term|
      ColognePhonetics.encode(term).presence
    end.uniq
  end

  private

  def letters
    word.name
      .downcase
      .gsub(/[^[:alpha:]]/, "")
      .chars
  end

  def cologne_phonetics_terms
    if word.respond_to?(:cologne_phonetics_terms, true)
      word.send(:cologne_phonetics_terms)
    else
      [word.name]
    end
  end
end
