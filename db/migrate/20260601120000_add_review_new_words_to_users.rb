# frozen_string_literal: true

class AddReviewNewWordsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :review_new_words, :boolean, default: true, null: false
  end
end
