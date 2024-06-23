class Theme < ApplicationRecord
  extend Enumerize

  WORD_CLASSES = [Noun, Verb, Adjective, FunctionWord].freeze
  WORD_TYPES = WORD_CLASSES.map(&:to_s).map(&:underscore).map(&:to_sym).freeze

  belongs_to :user

  enumerize :visibility, in: %i[private public], default: :private
  enumerize :word_type, in: WORD_TYPES, default: :noun, scope: true

  validates :name, presence: true, uniqueness: true
  validates :template, presence: true
  validates :visibility, presence: true
  validates :word_type, presence: true

  def self.default_template(word_type:)
    erb = File.read(Rails.root.join("app/views/themes/default_#{word_type}.liquid"))
    ERB.new(erb).result
  end
end
