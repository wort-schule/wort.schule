# frozen_string_literal: true

class WordImport < ApplicationRecord
  extend Enumerize

  validates :name, presence: true
  validates :topic, presence: true
  validates :word_type, presence: true

  enumerize :word_type, in: %i[Noun Verb Adjective FunctionWord]
  enumerize :state, in: %i[new failed], default: :new
end
