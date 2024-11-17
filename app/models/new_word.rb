# frozen_string_literal: true

class NewWord < ApplicationRecord
  extend Enumerize
  include Reviewable

  belongs_to :change_group
end
