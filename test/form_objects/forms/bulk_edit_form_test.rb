# frozen_string_literal: true

require "test_helper"

class Forms::BulkEditFormTest < ActiveSupport::TestCase
  setup do
    @user = create(:admin)
    @noun = create(:noun, name: "Haus")
    @phenomenon = create(:phenomenon, name: "P")
  end

  test "requires a field" do
    form = Forms::BulkEditForm.new({selected_ids: [@noun.id]}, user: @user)
    refute form.valid?
    assert form.errors[:field].any?
  end

  test "rejects an operation that doesn't fit the field type" do
    form = Forms::BulkEditForm.new(
      {selected_ids: [@noun.id], field: "prototype", operation: "add", value: "true"},
      user: @user
    )
    refute form.valid?
    assert form.errors[:operation].any?
  end

  test "rejects a blank boolean value (3-state 'unset' is not applyable)" do
    form = Forms::BulkEditForm.new(
      {selected_ids: [@noun.id], field: "foreign", operation: "set", value: ""},
      user: @user
    )
    refute form.valid?
    assert form.errors[:value].any?
  end

  test "rejects an empty word selection" do
    form = Forms::BulkEditForm.new(
      {field: "phenomenons", operation: "add", value: [@phenomenon.id.to_s]},
      user: @user
    )
    refute form.valid?
    assert form.errors[:base].any?
  end

  test "rejects more than MAX_WORDS_PER_OPERATION word ids" do
    BulkEdit.const_set(:MAX_WORDS_PER_OPERATION, 2)
    a, b, c = create_list(:noun, 3)
    form = Forms::BulkEditForm.new(
      {selected_ids: [a.id, b.id, c.id], field: "phenomenons", operation: "add", value: [@phenomenon.id.to_s]},
      user: @user
    )
    refute form.valid?
    assert_includes form.errors[:base].join, "2"
  ensure
    BulkEdit.const_set(:MAX_WORDS_PER_OPERATION, 5_000)
  end

  test "select_all=1 resolves word_ids from the search instead of explicit selection" do
    second = create(:noun, name: "Hand")
    form = Forms::BulkEditForm.new(
      {select_all: "1", q: "*", field: "phenomenons", operation: "add", value: [@phenomenon.id.to_s]},
      user: @user
    )
    assert_includes form.word_ids_for_apply, @noun.id
    assert_includes form.word_ids_for_apply, second.id
  end

  test "#to_service_args delegates value normalization to the strategy" do
    form = Forms::BulkEditForm.new(
      {selected_ids: [@noun.id], field: "phenomenons", operation: "add", value: [@phenomenon.id.to_s], q: "Haus*"},
      user: @user
    )
    assert form.valid?, form.errors.full_messages.inspect

    args = form.to_service_args
    assert_equal "phenomenons", args[:field]
    assert_equal({"ids" => [@phenomenon.id]}, args[:value])
    assert_equal "Haus*", args[:search_query]
  end
end
