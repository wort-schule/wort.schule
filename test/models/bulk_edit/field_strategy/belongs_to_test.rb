# frozen_string_literal: true

require "test_helper"

class BulkEdit::FieldStrategy::BelongsToTest < ActiveSupport::TestCase
  setup do
    @strategy = BulkEdit::FieldStrategy::BelongsTo.new("hierarchy_id")
    @word = create(:noun)
    @h1 = create(:hierarchy, name: "H1")
  end

  test "#normalize_input converts a string id to an integer" do
    assert_equal({"id" => 42}, @strategy.normalize_input("42"))
    assert_equal({"id" => 42}, @strategy.normalize_input(["42"]))
  end

  test "#normalize_input returns nil id for empty input (set-to-NULL is allowed)" do
    assert_equal({"id" => nil}, @strategy.normalize_input(""))
    assert_equal({"id" => nil}, @strategy.normalize_input([""]))
    assert_equal({"id" => nil}, @strategy.normalize_input(nil))
  end

  test "#apply updates the foreign key and records the previous value" do
    @word.update!(hierarchy_id: nil)
    result = @strategy.apply(@word, {"id" => @h1.id}, "set")

    assert_equal @h1.id, @word.reload.hierarchy_id
    assert_equal({previous: {"id" => nil}, applied: {"id" => @h1.id}}, result)
  end

  test "#apply sets the foreign key to NULL when value is nil" do
    @word.update!(hierarchy_id: @h1.id)
    result = @strategy.apply(@word, {"id" => nil}, "set")

    assert_nil @word.reload.hierarchy_id
    assert_equal({previous: {"id" => @h1.id}, applied: {"id" => nil}}, result)
  end

  test "#apply is a no-op when old value equals new value" do
    @word.update!(hierarchy_id: @h1.id)
    assert_nil @strategy.apply(@word, {"id" => @h1.id}, "set")
  end

  test "#revert restores the previous foreign key" do
    @word.update!(hierarchy_id: @h1.id)
    change = BulkEditChange.new(previous_value: {"id" => nil}, applied_value: {"id" => @h1.id})
    @strategy.revert(@word, change)
    assert_nil @word.reload.hierarchy_id
  end

  test "#display_current uses the preloaded association" do
    @word.update!(hierarchy_id: @h1.id)
    assert_equal "H1", @strategy.display_current(@word.reload)
  end

  test "#display_current returns the locale 'none' placeholder when the value is nil" do
    assert_equal I18n.t("bulk_edits.values.none"), @strategy.display_current(@word)
  end

  test "#display_value resolves the value hash to the associated record name" do
    assert_equal "H1", @strategy.display_value({"id" => @h1.id})
    assert_equal I18n.t("bulk_edits.values.none"), @strategy.display_value({"id" => nil})
  end

  test "#missing_scope returns words with a nil foreign key" do
    with_h = create(:noun, hierarchy: @h1)
    without_h = create(:noun, hierarchy: nil)
    scope = @strategy.missing_scope(Word.all)

    assert_includes scope, without_h
    refute_includes scope, with_h
  end
end
