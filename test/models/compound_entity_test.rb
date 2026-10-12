# frozen_string_literal: true

require "test_helper"
require Rails.root.join("db/migrate/20261012090000_fix_compound_phonem_reduction_part_type")
require Rails.root.join("db/migrate/20261012090100_add_word_foreign_key_to_compound_entities")
require Rails.root.join("db/migrate/20261012100000_remove_compound_entities_without_part")

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

  test "a compound part that is used in a word cannot be destroyed" do
    reduction = create(:compound_phonem_reduction)
    create(:compound_entity, part: reduction)

    assert_not reduction.destroy
    assert reduction.errors.of_kind?(:base, :"restrict_dependent_destroy.has_many")
    assert CompoundPhonemReduction.exists?(reduction.id)
  end

  test "a word that is part of another word cannot be destroyed" do
    part = create(:noun, name: "Stift")
    create(:compound_entity, part: part)

    assert_not part.destroy
    assert part.errors.of_kind?(:base, :"restrict_dependent_destroy.has_many")
    assert Word.exists?(part.id)
  end

  test "a compound part knows every word it is used in" do
    reduction = create(:compound_phonem_reduction)
    first = create(:compound_entity, part: reduction)
    second = create(:compound_entity, part: reduction)

    assert_equal [first.word, second.word].sort_by(&:id), reduction.words.sort_by(&:id)
  end

  test "#to_s is empty when the part is gone" do
    entity = create(:compound_entity, part: create(:compound_phonem_reduction))
    CompoundPhonemReduction.where(id: entity.part_id).delete_all

    assert_equal "", entity.reload.to_s
  end

  test "the migration removes compound entities whose part is gone" do
    kept = create(:compound_entity, part: create(:compound_phonem_reduction))
    without_reduction = create(:compound_entity, part: create(:compound_phonem_reduction))
    without_word = create(:compound_entity, part: create(:noun))

    # delete_all skips the model callbacks, the way rows were lost before.
    CompoundPhonemReduction.where(id: without_reduction.part_id).delete_all
    Word.where(id: without_word.part_id).delete_all

    ActiveRecord::Migration.suppress_messages do
      RemoveCompoundEntitiesWithoutPart.new.up
    end

    assert_not CompoundEntity.exists?(without_reduction.id)
    assert_not CompoundEntity.exists?(without_word.id)
    assert CompoundEntity.exists?(kept.id)
  end
end
