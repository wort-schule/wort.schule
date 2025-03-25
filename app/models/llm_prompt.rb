class LlmPrompt < ApplicationRecord
  validates :identifier, presence: true
  validates :content, presence: true
end
