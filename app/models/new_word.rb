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

  def process_unlisted_keywords
    keyword = created_word || duplicate_word

    transaction do
      UnlistedKeyword.unprocessed.where(new_word: self).find_each do |unlisted|
        unlisted.word.keywords << keyword
        unlisted.word.save!
        unlisted.update!(state: "processed")
      end
    end
  end
end
