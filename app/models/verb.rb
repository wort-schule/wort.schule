# German verb (Verb) - STI subclass of Word.
#
# Specific attributes:
# - participle: present participle (Partizip I)
# - past_participle: past participle (Partizip II)
# - infinitive_with_zu: infinitive with "zu"
# - auxiliary_verb: auxiliary verb used (haben/sein)
# - verb_type: type of verb (regular, irregular, modal, etc.)
class Verb < Word
  validates_presence_of :name

  def self.dummy
    new(
      meaning: "",
      meaning_long: "",
      prototype: false,
      foreign: false,
      compound: false,
      prefix_id: nil,
      postfix_id: nil,
      name: "rennen",
      consonant_vowel: "KVKKVK",
      syllables: "ren-nen",
      written_syllables: "",
      participle: "rennend",
      past_participle: "gerannt",
      present_singular_1: "renne",
      present_singular_2: "rennst",
      present_singular_3: "rennt",
      present_plural_1: "rennen",
      present_plural_2: "rennt",
      present_plural_3: "rennen",
      past_singular_1: "rannte",
      past_singular_2: "ranntest",
      past_singular_3: "rannten",
      past_plural_1: "rannten",
      past_plural_2: "ranntet",
      past_plural_3: "rannten",
      subjectless: false,
      perfect_haben: false,
      perfect_sein: false,
      imperative_singular: nil,
      imperative_plural: nil,
      modal: false,
      strong: false
    )
  end

  private

  def cologne_phonetics_terms
    [
      name,
      participle,
      past_participle,
      present_singular_1,
      present_singular_2,
      present_singular_3,
      present_plural_1,
      present_plural_2,
      present_plural_3,
      past_singular_1,
      past_singular_2,
      past_singular_3,
      past_plural_1,
      past_plural_2,
      past_plural_3
    ]
  end
end
