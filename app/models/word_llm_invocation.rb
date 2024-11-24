# frozen_string_literal: true

class WordLlmInvocation < ApplicationRecord
  extend Enumerize

  enumerize :state, in: %i[invoked failed completed], default: :invoked
  enumerize :invocation_type, in: %i[enrichment check_base_form]
end
