# frozen_string_literal: true

# Provides common collection methods for models with name attributes.
# Includes methods for retrieving distinct values and id/name pairs for form selects.
module Collectable
  extend ActiveSupport::Concern

  class_methods do
    # Returns an array of distinct names, sorted alphabetically
    # @return [Array<String>] sorted array of distinct names
    def values
      distinct.pluck(:name).sort
    end

    # Returns an array of [id, name] pairs for use in form selects
    # @return [Array<Array(Integer, String)>] array of [id, name] pairs, ordered by name
    def collection
      distinct.order(:name).pluck(:id, :name)
    end
  end
end
