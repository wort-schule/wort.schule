# frozen_string_literal: true

require "test_helper"

class BulkEditTest < ActiveSupport::TestCase
  test "rejects an unknown field" do
    record = build(:bulk_edit, field: "nonsense")
    refute record.valid?
    assert record.errors[:field].any?
  end

  test "rejects an unknown operation" do
    record = build(:bulk_edit, operation: "frobnicate")
    refute record.valid?
    assert record.errors[:operation].any?
  end

  test "rejects an operation that doesn't fit the field type" do
    record = build(:bulk_edit, field: "prototype", operation: "add", intent_value: {"value" => true})
    refute record.valid?
    assert record.errors[:operation].any?
  end

  test "accepts add/remove for HABTM fields" do
    record = build(:bulk_edit, field: "phenomenons", operation: "remove")
    assert record.valid?, record.errors.full_messages.inspect
  end

  test "accepts set for belongs_to fields" do
    record = build(:bulk_edit, field: "hierarchy_id", operation: "set", intent_value: {"id" => nil})
    assert record.valid?, record.errors.full_messages.inspect
  end

  test "accepts set for boolean fields" do
    record = build(:bulk_edit, field: "foreign", operation: "set", intent_value: {"value" => true})
    assert record.valid?, record.errors.full_messages.inspect
  end

  test ".undoable_by returns all entries for an Admin" do
    admin = create(:admin)
    lecturer = create(:lecturer)
    by_admin = create(:bulk_edit, user: admin)
    by_lecturer = create(:bulk_edit, user: lecturer)

    assert_equal [by_admin, by_lecturer].sort, BulkEdit.undoable_by(admin).order(:id).to_a
  end

  test ".undoable_by limits a Lecturer to their own entries" do
    lecturer_a = create(:lecturer)
    lecturer_b = create(:lecturer)
    own = create(:bulk_edit, user: lecturer_a)
    create(:bulk_edit, user: lecturer_b)

    assert_equal [own], BulkEdit.undoable_by(lecturer_a).to_a
  end

  test "#undoable_by? returns false once the entry is undone" do
    admin = create(:admin)
    record = create(:bulk_edit, user: admin, undone_at: Time.current)
    refute record.undoable_by?(admin)
  end

  test "#undoable_by? lets an Admin undo any entry" do
    admin = create(:admin)
    lecturer = create(:lecturer)
    record = create(:bulk_edit, user: lecturer)
    assert record.undoable_by?(admin)
  end

  test "#undoable_by? lets a Lecturer undo only their own entries" do
    lecturer_a = create(:lecturer)
    lecturer_b = create(:lecturer)
    own = create(:bulk_edit, user: lecturer_a)

    assert own.undoable_by?(lecturer_a)
    refute own.undoable_by?(lecturer_b)
  end

  test "#strategy returns the matching strategy" do
    record = build(:bulk_edit, field: "hierarchy_id", operation: "set", intent_value: {"id" => nil})
    assert_kind_of BulkEdit::FieldStrategy::BelongsTo, record.strategy
  end

  test "#field_label and #display_intent delegate to the strategy" do
    hierarchy = create(:hierarchy, name: "Säugetier")
    record = build(:bulk_edit, field: "hierarchy_id", operation: "set", intent_value: {"id" => hierarchy.id})

    assert_equal Word.human_attribute_name(:hierarchy), record.field_label
    assert_equal "Säugetier", record.display_intent
  end
end
