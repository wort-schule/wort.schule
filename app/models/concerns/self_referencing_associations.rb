# frozen_string_literal: true

# Provides helper for creating self-referential associations on Word models.
# These associations prevent duplicate entries and self-references.
module SelfReferencingAssociations
  extend ActiveSupport::Concern

  # Extension module for self-referential associations
  # Prevents adding self-references and duplicates
  module AssociationExtension
    # Override << to prevent adding self-references and duplicates
    def <<(group)
      group -= self if group.respond_to?(:to_a)
      super(group) unless include?(group)
    end
  end

  class_methods do
    # Creates a self-referential has_and_belongs_to_many association with Word
    # that prevents duplicates and self-references.
    #
    # @param name [Symbol] the name of the association (e.g., :keywords)
    # @param association_key [Symbol] the foreign key in the join table (e.g., :keyword_id)
    def has_self_referential_association(name, association_key)
      has_and_belongs_to_many name,
        -> { distinct.order(:name) },
        class_name: "Word",
        join_table: name,
        foreign_key: :word_id,
        association_foreign_key: association_key,
        extend: AssociationExtension
    end
  end
end
