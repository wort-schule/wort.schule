# frozen_string_literal: true

require "test_helper"

class BulkEditServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:admin)
    @service = BulkEditService.new(user: @user)
    @noun1 = create(:noun, name: "Haus")
    @noun2 = create(:noun, name: "Hof")
    @p1 = create(:phenomenon, name: "P1")
  end

  test "#execute applies HABTM add and stores one change per affected word" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id, @noun2.id],
      field: "phenomenons",
      operation: "add",
      value: {"ids" => [@p1.id]},
      search_query: "H*"
    )

    assert_equal 2, bulk_edit.affected_count
    assert_equal 2, bulk_edit.word_changes.count
    assert_equal({"ids" => [@p1.id]}, bulk_edit.intent_value)
    assert_includes @noun1.reload.phenomenons, @p1
    assert_includes @noun2.reload.phenomenons, @p1
  end

  test "#execute creates no BulkEdit when nothing actually changes" do
    @noun1.phenomenons << @p1
    @noun2.phenomenons << @p1

    assert_no_difference -> { BulkEdit.count } do
      result = @service.execute(
        word_ids: [@noun1.id, @noun2.id],
        field: "phenomenons",
        operation: "add",
        value: {"ids" => [@p1.id]}
      )
      assert_nil result
    end
  end

  test "#execute stores only the per-word delta, not the full requested set" do
    @noun1.phenomenons << @p1
    p2 = create(:phenomenon, name: "P2")

    bulk_edit = @service.execute(
      word_ids: [@noun1.id, @noun2.id],
      field: "phenomenons",
      operation: "add",
      value: {"ids" => [@p1.id, p2.id]}
    )

    changes = bulk_edit.word_changes.index_by(&:word_id)
    assert_equal [p2.id], changes[@noun1.id].applied_value["ids"]
    assert_equal [@p1.id, p2.id].sort, changes[@noun2.id].applied_value["ids"].sort
  end

  test "#execute raises ArgumentError when operation doesn't fit the field" do
    assert_raises(ArgumentError) do
      @service.execute(
        word_ids: [@noun1.id],
        field: "prototype",
        operation: "add",
        value: {"value" => true}
      )
    end
  end

  test "#execute applies a belongs_to 'set' to the foreign key" do
    hierarchy = create(:hierarchy, name: "Säugetier")
    bulk_edit = @service.execute(
      word_ids: [@noun1.id],
      field: "hierarchy_id",
      operation: "set",
      value: {"id" => hierarchy.id}
    )

    assert_equal hierarchy.id, @noun1.reload.hierarchy_id
    assert_equal({"id" => hierarchy.id}, bulk_edit.word_changes.first.applied_value)
  end

  test "#execute applies a boolean 'set' to false" do
    @noun1.update!(foreign: true)
    bulk_edit = @service.execute(
      word_ids: [@noun1.id],
      field: "foreign",
      operation: "set",
      value: {"value" => false}
    )

    refute @noun1.reload.foreign
    assert_equal({"value" => false}, bulk_edit.word_changes.first.applied_value)
  end

  test "#undo reverts every pending change and marks the header as undone" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id, @noun2.id],
      field: "phenomenons",
      operation: "add",
      value: {"ids" => [@p1.id]}
    )
    @service.undo(bulk_edit)

    assert bulk_edit.reload.undone_at.present?
    assert_empty @noun1.reload.phenomenons.to_a
    assert_empty @noun2.reload.phenomenons.to_a
    assert_empty bulk_edit.word_changes.pending.to_a
  end

  test "#undo raises AlreadyUndone on a second call" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id], field: "phenomenons", operation: "add", value: {"ids" => [@p1.id]}
    )
    @service.undo(bulk_edit)
    assert_raises(BulkEditService::AlreadyUndone) { @service.undo(bulk_edit) }
  end

  test "#undo tolerates a word that was deleted between execute and undo" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id], field: "phenomenons", operation: "add", value: {"ids" => [@p1.id]}
    )
    @noun1.destroy

    assert_nothing_raised { @service.undo(bulk_edit) }
    assert bulk_edit.reload.undone_at.present?
  end

  test "#undo_change reverts a single change and leaves siblings pending" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id, @noun2.id], field: "phenomenons", operation: "add", value: {"ids" => [@p1.id]}
    )
    change = bulk_edit.word_changes.find_by(word: @noun1)
    @service.undo_change(change)

    assert change.reload.reverted_at.present?
    assert_empty @noun1.reload.phenomenons.to_a
    assert_includes @noun2.reload.phenomenons, @p1
    assert_nil bulk_edit.reload.undone_at
  end

  test "#undo_change auto-completes the header when reverting the last pending change" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id], field: "phenomenons", operation: "add", value: {"ids" => [@p1.id]}
    )
    @service.undo_change(bulk_edit.word_changes.first)
    assert bulk_edit.reload.undone_at.present?
  end

  test "#undo_change raises AlreadyReverted on a second call" do
    bulk_edit = @service.execute(
      word_ids: [@noun1.id], field: "phenomenons", operation: "add", value: {"ids" => [@p1.id]}
    )
    change = bulk_edit.word_changes.first
    @service.undo_change(change)
    assert_raises(BulkEditService::AlreadyReverted) { @service.undo_change(change.reload) }
  end

  test "#execute supports 'sources' as a HABTM field" do
    source = create(:source, name: "Wiktionary")
    bulk_edit = @service.execute(
      word_ids: [@noun1.id], field: "sources", operation: "add", value: {"ids" => [source.id]}
    )

    assert_equal 1, bulk_edit.affected_count
    assert_includes @noun1.reload.sources, source
  end
end
