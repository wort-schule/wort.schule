# German function word (Funktionswort) - STI subclass of Word.
#
# Represents grammatical words like articles, pronouns, prepositions, and conjunctions.
#
# Specific attributes:
# - function_type: type of function word (article, pronoun, preposition, conjunction, etc.)
class FunctionWord < Word
  validates_presence_of :name, :function_type

  enum :function_type, {article_definite: 0,
                        article_indefinite: 1,
                        auxiliary_verb: 2,
                        conjunction: 3,
                        preposition: 4,
                        pronoun: 5}

  def function_type_text
    I18n.t function_type, scope: %i[activerecord attributes function_word function_types]
  end

  def self.function_types_collection
    function_types.map do |key, value|
      [
        I18n.t(key, scope: %i[activerecord attributes function_word function_types]),
        key
      ]
    end
  end

  def self.dummy
    new(
      name: "das",
      function_type: 0,
      syllables: "",
      written_syllables: ""
    )
  end
end
