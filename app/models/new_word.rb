# frozen_string_literal: true

class NewWord < ApplicationRecord
  extend Enumerize
  include Reviewable

  belongs_to :change_group
  belongs_to :duplicate_word, class_name: "Word", optional: true
  belongs_to :created_word, class_name: "Word", optional: true
  has_many :unlisted_keywords, dependent: :destroy

  enumerize :word_type, in: %w[Noun Verb Adjective FunctionWord]

  validates :word_type, presence: true
  validates :name, presence: true

  def process_unlisted_keywords
    keyword = created_word || duplicate_word
    return unless keyword

    transaction do
      unlisted_keywords = UnlistedKeyword.unprocessed.where(new_word: self).includes(:word).to_a
      return if unlisted_keywords.empty?

      # Batch update all words' keywords at once
      word_ids = unlisted_keywords.map(&:word_id).uniq
      Word.where(id: word_ids).find_each do |word|
        word.keywords << keyword unless word.keywords.include?(keyword)
        word.save!
      end

      # Batch update all unlisted keywords to processed
      UnlistedKeyword.where(id: unlisted_keywords.map(&:id)).update_all(state: "processed")
    end
  end
end
