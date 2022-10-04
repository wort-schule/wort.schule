class ExampleSentence < ApplicationRecord
  belongs_to :word

  validates_presence_of :sentence
end
