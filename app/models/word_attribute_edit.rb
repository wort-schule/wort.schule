# frozen_string_literal: true

class WordAttributeEdit < ApplicationRecord
  extend Enumerize

  belongs_to :word, polymorphic: true

  enumerize :state, in: %i[waiting_for_review], default: :waiting_for_review
end
