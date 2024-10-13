# frozen_string_literal: true

class WordLlmEnrichment < ApplicationRecord
  extend Enumerize

  belongs_to :word, polymorphic: true

  enumerize :state, in: %i[invoked failed completed], default: :invoked
end
