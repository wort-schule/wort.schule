class Word < ApplicationRecord
  has_many :related_example_sentences, class_name: 'ExampleSentence', foreign_key: :word_id
end

class Noun < Word
  has_many :related_example_sentences, class_name: 'ExampleSentence', foreign_key: :word_id
end

class Verb < Word
  has_many :related_example_sentences, class_name: 'ExampleSentence', foreign_key: :word_id
end

class Adjective < Word
  has_many :related_example_sentences, class_name: 'ExampleSentence', foreign_key: :word_id
end

class ExampleSentence < ApplicationRecord
  belongs_to :word
end

class AddExampleSentencesToWords < ActiveRecord::Migration[7.0]
  def up
    add_column :words, :example_sentences, :jsonb, null: false, default: []

    Word.find_each do |word|
      word.update_attribute(
        :example_sentences,
        word.related_example_sentences.map(&:sentence)
      )
    end

    drop_table :example_sentences
  end

  def down
    create_table "example_sentences", force: :cascade do |t|
      t.string "sentence"
      t.bigint "word_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["word_id"], name: "index_example_sentences_on_word_id"
    end

    Word.find_each do |word|
      word.example_sentences.each do |sentence|
        ExampleSentence.create!(word:, sentence:)
      end
    end

    remove_column :words, :example_sentences, :jsonb, null: true
  end
end
