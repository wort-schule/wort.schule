# frozen_string_literal: true

class GlobalSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  class << self
    def reviews_required
      find_by(key: "reviews_required")&.integer_value || 1
    end

    def reviews_required=(value)
      record = find_or_create_by(key: "reviews_required")
      record.update!(integer_value: value)
    end
  end
end
