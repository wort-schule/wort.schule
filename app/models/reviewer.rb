# frozen_string_literal: true

class Reviewer < ApplicationRecord
  belongs_to :word_attribute_edit
  belongs_to :reviewer, class_name: "User"

  def readonly?
    true
  end
end
