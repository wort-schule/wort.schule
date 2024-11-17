# frozen_string_literal: true

class WordLlmInvocation < ApplicationRecord
  extend Enumerize

  belongs_to :word, polymorphic: true

  enumerize :state, in: %i[invoked failed completed], default: :invoked
  enumerize :invocation_type, in: %i[enrichment]
end
