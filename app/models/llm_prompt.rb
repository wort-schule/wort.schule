# frozen_string_literal: true

class LlmPrompt < ApplicationRecord
  validates :identifier, presence: true
end
