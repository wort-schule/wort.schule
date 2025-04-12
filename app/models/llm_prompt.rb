class LlmPrompt < ApplicationRecord
  validates :identifier, presence: true
end
