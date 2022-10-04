class Verb < ApplicationRecord
  default_scope { joins(:word) }
  acts_as :word
  validates_presence_of :name

  include WordFilter
end
