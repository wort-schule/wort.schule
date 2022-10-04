# frozen_string_literal: true

class TeachingAssignment < ApplicationRecord
  belongs_to :school
  belongs_to :teacher, class_name: "User"
end
