# frozen_string_literal: true

class GlobalSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  class << self
    def reviews_required
      return 1 unless table_exists?
      find_by(key: "reviews_required")&.integer_value || 1
    rescue
      1
    end

    def reviews_required=(value)
      return unless table_exists?
      record = find_or_create_by(key: "reviews_required")
      record.update!(integer_value: value)
    rescue
      nil
    end
  end
end
