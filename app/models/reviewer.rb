# frozen_string_literal: true

class Reviewer < ApplicationRecord
  belongs_to :change_group
  belongs_to :reviewer, class_name: "User"

  def readonly?
    true
  end
end
