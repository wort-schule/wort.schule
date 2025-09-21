# frozen_string_literal: true

class LearningPlea < ApplicationRecord
  belongs_to :learning_group
  belongs_to :list
end
