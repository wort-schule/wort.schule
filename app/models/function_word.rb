class FunctionWord < ApplicationRecord
  acts_as :word
  validates_presence_of :name, :function_type

  enum function_type: {article_definite: 0,
                       article_indefinite: 1,
                       auxiliary_verb: 2,
                       conjunction: 3,
                       preposition: 4,
                       pronoun: 5}

  def self.function_types_collection
    function_types.map do |key, value|
      [
        I18n.t(key, scope: %i[activerecord attributes function_word function_types]),
        key
      ]
    end
  end
end
