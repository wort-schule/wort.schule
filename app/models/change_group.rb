# frozen_string_literal: true

class ChangeGroup < ApplicationRecord
  extend Enumerize
  include Reviewable

  enumerize :state, in: %i[waiting_for_review edited confirmed invalid created duplicate discarded], default: :waiting_for_review

  has_many :word_attribute_edits,
    # In Rails 8, replace with:
    # in_order_of(:attribute_name, Llm::Enrich::ATTRIBUTE_GROUPS.flatten.map(&:to_s), filter: false)
    lambda {
      column = :attribute_name
      values = Llm::Enrich::ATTRIBUTE_GROUPS.flatten.map(&:to_s)

      model.disallow_raw_sql!([column], permit: model.adapter_class.column_name_with_order_matcher)
      return spawn.none! if values.empty?

      references = column_references([column])
      self.references_values |= references unless references.empty?

      values = values.map { |value| model.type_caster.type_cast_for_database(column, value) }
      arel_column = column.is_a?(Arel::Nodes::SqlLiteral) ? column : order_column(column.to_s)

      spawn.order!(build_case_for_value_position(arel_column, values))
    },
    dependent: :destroy
  has_one :new_word, dependent: :destroy

  accepts_nested_attributes_for :word_attribute_edits, :new_word
end
