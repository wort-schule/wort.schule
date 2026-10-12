# frozen_string_literal: true

require "test_helper"
require Rails.root.join("db/migrate/20261012090000_fix_compound_phonem_reduction_part_type")
require Rails.root.join("db/migrate/20261012090100_add_word_foreign_key_to_compound_entities")

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

  test "destroying a word destroys its compound entities" do
    entity = create(:compound_entity)

    entity.word.destroy!

    assert_not CompoundEntity.exists?(entity.id)
  end

  test "the database removes compound entities when a word is deleted without callbacks" do
    entity = create(:compound_entity)

    Word.where(id: entity.word_id).delete_all

    assert_not CompoundEntity.exists?(entity.id)
  end

  test "the migration removes compound entities whose word is gone" do
    kept = create(:compound_entity)
    orphan = create(:compound_entity)
    connection = ActiveRecord::Base.connection

    # Recreate the state before the migration: no foreign key, one orphan.
    if connection.foreign_key_exists?(:compound_entities, :words)
      connection.remove_foreign_key :compound_entities, :words
    end
    Word.where(id: orphan.word_id).delete_all

    ActiveRecord::Migration.suppress_messages do
      AddWordForeignKeyToCompoundEntities.new.up
    end

    assert_not CompoundEntity.exists?(orphan.id)
    assert CompoundEntity.exists?(kept.id)
    assert connection.foreign_key_exists?(:compound_entities, :words)
  end
end
