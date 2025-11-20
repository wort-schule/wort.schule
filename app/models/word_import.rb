# frozen_string_literal: true

class WordImport < ApplicationRecord
  extend Enumerize

  validates :name, presence: true
  validates :word_type, presence: true

  enumerize :word_type, in: %i[Noun Verb Adjective FunctionWord]
  enumerize :state, in: %i[new failed completed], default: :new
end
