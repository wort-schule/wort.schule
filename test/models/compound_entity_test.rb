# frozen_string_literal: true

require "test_helper"
require Rails.root.join("db/migrate/20261012090000_fix_compound_phonem_reduction_part_type")

class CompoundEntityTest < ActiveSupport::TestCase
  test "#part loads a phoneme reduction" do
    reduction = create(:compound_phonem_reduction)
    entity = create(:compound_entity, part: reduction)

    assert_equal "CompoundPhonemReduction", entity.part_type
    assert_equal reduction, entity.reload.part
  end

  test "is invalid when the part is not a compound part" do
    entity = build(:compound_entity, part: create(:user))

    assert_not entity.valid?
    assert entity.errors.of_kind?(:part_type, :inclusion)
  end

  test "the migration repairs rows that still carry the pre-rename part_type" do
    reduction = create(:compound_phonem_reduction)
    entity = create(:compound_entity, part: reduction)
    entity.update_column(:part_type, "CompoundPhonemreduction")

    ActiveRecord::Migration.suppress_messages do
      FixCompoundPhonemReductionPartType.new.up
    end

    assert_equal reduction, entity.reload.part
  end
end
