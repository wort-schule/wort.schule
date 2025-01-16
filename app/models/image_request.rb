# frozen_string_literal: true

class ImageRequest < ApplicationRecord
  belongs_to :word
  belongs_to :user

  validates :word, uniqueness: {scope: :user_id}
end
