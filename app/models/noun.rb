# German noun (Substantiv/Nomen) - STI subclass of Word.
#
# Specific attributes:
# - genus: grammatical gender (masculinum, femininum, neutrum)
# - plural: plural form
# - genitive: genitive case form
# - article_definite: definite article (der/die/das)
# - article_indefinite: indefinite article (ein/eine)
class Noun < Word
  belongs_to :genus, optional: true
  validates :name, presence: true

  belongs_to :genus_masculine, class_name: "Noun", optional: true
  belongs_to :genus_feminine, class_name: "Noun", optional: true
  belongs_to :genus_neuter, class_name: "Noun", optional: true

  scope :by_genus, ->(genus) {
    where(genus: Genus.find_by(name: genus))
  }

  # Article lookup table for better readability and performance
  # Structure: [case_number][singular?][genus_id]
  ARTICLE_LOOKUP = {
    1 => {
      true => %w[der die das der/die der/das die/das der/die/das],
      false => "die"
    },
    2 => {
      true => %w[des der des des/der des der/des des/der],
      false => "der"
    },
    3 => {
      true => %w[dem der dem dem/der dem der/dem dem/der],
      false => "den"
    },
    4 => {
      true => %w[den die das den/die den/das die/das den/die/das],
      false => "die"
    }
  }.freeze

  def article_definite(case_number: 1, singular: true)
    return "" if genus_id.blank? && singular

    lookup = ARTICLE_LOOKUP[case_number]
    return "" unless lookup

    if singular
      lookup[true][genus_id]
    else
      lookup[false]
    end
  end

  def article_indefinite
    %w[ein eine ein ein/eine ein eine/ein ein/eine][genus_id] unless genus_id.nil?
  end

  def full_name
    [article_definite, name].select(&:present?).join(" ")
  end

  def full_plural
    return "" if plural.blank?

    [article_definite(singular: false), plural].select(&:present?).join(" ")
  end

  def self.dummy
    new(
      meaning: "",
      meaning_long: "Tier, klettert",
      prototype: false,
      foreign: false,
      compound: false,
      prefix_id: nil,
      postfix_id: nil,
      name: "Affe",
      consonant_vowel: "VKKV",
      syllables: "Af-fen",
      written_syllables: "",
      plural: "Affen",
      genus_id: 0,
      genus_masculine_id: nil,
      genus_feminine_id: nil,
      genus_neuter_id: nil,
      case_1_singular: "Affe",
      case_1_plural: "Affen",
      case_2_singular: "Affen",
      case_2_plural: "Affen",
      case_3_singular: "Affen",
      case_3_plural: "Affen",
      case_4_singular: "Affen",
      case_4_plural: "Affen",
      pluraletantum: false,
      singularetantum: false
    )
  end

  private

  def cologne_phonetics_terms
    [
      name,
      plural
    ]
  end
end
