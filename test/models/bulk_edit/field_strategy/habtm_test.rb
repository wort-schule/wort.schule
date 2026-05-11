# frozen_string_literal: true

require "test_helper"

class BulkEdit::FieldStrategy::HabtmTest < ActiveSupport::TestCase
  setup do
    @strategy = BulkEdit::FieldStrategy::Habtm.new("phenomenons")
    @word = create(:noun)
    @p1 = create(:phenomenon, name: "P1")
    @p2 = create(:phenomenon, name: "P2")
  end

  test "#normalize_input returns an ids hash for arrays" do
    assert_equal({"ids" => [@p1.id, @p2.id]}, @strategy.normalize_input([@p1.id, @p2.id]))
  end

  test "#normalize_input rejects zero and blank entries and deduplicates" do
    assert_equal({"ids" => [@p1.id]}, @strategy.normalize_input([@p1.id, @p1.id, 0, ""]))
  end

  test "#normalize_input returns nil for empty input" do
    assert_nil @strategy.normalize_input([])
    assert_nil @strategy.normalize_input(nil)
  end

  test "#apply 'add' attaches missing ids and reports the delta" do
    result = @strategy.apply(@word, {"ids" => [@p1.id]}, "add")
    assert_equal [@p1], @word.reload.phenomenons.to_a
    assert_equal({previous: {"ids" => []}, applied: {"ids" => [@p1.id]}}, result)
  end

  test "#apply 'add' is a no-op when the value is already present" do
    @word.phenomenons << @p1
    assert_nil @strategy.apply(@word, {"ids" => [@p1.id]}, "add")
  end

  test "#apply 'add' stores only the delta when value is partially present" do
    @word.phenomenons << @p1
    result = @strategy.apply(@word, {"ids" => [@p1.id, @p2.id]}, "add")
    assert_equal [@p2.id], result[:applied]["ids"]
  end

  test "#apply 'remove' detaches the requested ids and reports the delta" do
    @word.phenomenons << @p1
    result = @strategy.apply(@word, {"ids" => [@p1.id]}, "remove")
    assert_empty @word.reload.phenomenons.to_a
    assert_equal({previous: {"ids" => [@p1.id]}, applied: {"ids" => []}}, result)
  end

  test "#apply 'remove' is a no-op when the value is not present" do
    assert_nil @strategy.apply(@word, {"ids" => [@p1.id]}, "remove")
  end

  test "#revert reverses an add by removing the added ids" do
    @word.phenomenons << @p1
    change = build_change(applied: {"ids" => [@p1.id]}, previous: {"ids" => []})
    @strategy.revert(@word, change)
    assert_empty @word.reload.phenomenons.to_a
  end

  test "#revert reverses a remove by re-attaching the previous ids" do
    change = build_change(applied: {"ids" => []}, previous: {"ids" => [@p1.id]})
    @strategy.revert(@word, change)
    assert_equal [@p1], @word.reload.phenomenons.to_a
  end

  test "#revert is idempotent when the value is already present" do
    @word.phenomenons << @p1
    change = build_change(applied: {"ids" => []}, previous: {"ids" => [@p1.id]})
    assert_no_difference -> { @word.reload.phenomenons.count } do
      @strategy.revert(@word, change)
    end
  end

  test "#current_value returns the ids of the associated records" do
    @word.phenomenons << [@p1, @p2]
    assert_equal [@p1.id, @p2.id].sort, @strategy.current_value(@word.reload).sort
  end

  test "#display_current returns the locale 'none' placeholder when empty" do
    assert_equal I18n.t("bulk_edits.values.none"), @strategy.display_current(@word)
  end

  test "#display_current joins associated names with commas" do
    @word.phenomenons << @p1
    assert_equal "P1", @strategy.display_current(@word.reload)
  end

  test "#missing_scope returns words without this HABTM association" do
    with_p = create(:noun)
    with_p.phenomenons << @p1
    without_p = create(:noun)
    scope = @strategy.missing_scope(Word.all)

    assert_includes scope, without_p
    refute_includes scope, with_p
  end

  private

  def build_change(applied:, previous:)
    BulkEditChange.new(applied_value: applied, previous_value: previous)
  end
end
