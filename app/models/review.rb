# frozen_string_literal: true

class Review < ApplicationRecord
  extend Enumerize

  belongs_to :reviewable, polymorphic: true
  belongs_to :reviewer, class_name: "User"

  enumerize :state, in: %i[skipped edited confirmed created duplicate discarded]
end
