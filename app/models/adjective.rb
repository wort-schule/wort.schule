class Adjective < Word
  validates_presence_of :name

  def self.dummy
    new(
      name: "schön",
      meaning: "",
      meaning_long: "",
      prototype: false,
      foreign: false,
      compound: false,
      prefix_id: nil,
      postfix_id: nil,
      consonant_vowel: "KKKVK",
      syllables: "schön",
      written_syllables: "",
      comparative: "schöner",
      superlative: "schönsten",
      absolute: false,
      irregular_declination: false,
      irregular_comparison: false
    )
  end
end
