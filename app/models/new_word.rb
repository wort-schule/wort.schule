# frozen_string_literal: true

class NewWord < ApplicationRecord
  extend Enumerize
  include Reviewable

  belongs_to :change_group
  belongs_to :duplicate_word, class_name: "Word", optional: true
  belongs_to :created_word, class_name: "Word", optional: true

  enumerize :word_type, in: %w[Noun Verb Adjective FunctionWord]

  validates :word_type, presence: true
  validates :name, presence: true
  validates :topic, presence: true
end
