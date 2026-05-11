# frozen_string_literal: true

require "test_helper"

class BulkEdit::FieldStrategy::BooleanTest < ActiveSupport::TestCase
  setup do
    @strategy = BulkEdit::FieldStrategy::Boolean.new("foreign")
    @word = create(:noun)
  end

  test "#normalize_input casts strings to booleans" do
    assert_equal({"value" => true}, @strategy.normalize_input("true"))
    assert_equal({"value" => false}, @strategy.normalize_input("false"))
    assert_equal({"value" => true}, @strategy.normalize_input(["true"]))
  end

  test "#normalize_input returns nil for the 3-state 'unset' option" do
    assert_nil @strategy.normalize_input("")
    assert_nil @strategy.normalize_input([""])
    assert_nil @strategy.normalize_input(nil)
  end

  test "#apply sets the boolean to true and records the previous value" do
    @word.update!(foreign: false)
    result = @strategy.apply(@word, {"value" => true}, "set")

    assert @word.reload.foreign
    assert_equal({previous: {"value" => false}, applied: {"value" => true}}, result)
  end

  test "#apply sets the boolean to false (from true)" do
    @word.update!(foreign: true)
    result = @strategy.apply(@word, {"value" => false}, "set")

    refute @word.reload.foreign
    assert_equal({previous: {"value" => true}, applied: {"value" => false}}, result)
  end

  test "#apply is a no-op when the value is unchanged" do
    @word.update!(foreign: true)
    assert_nil @strategy.apply(@word, {"value" => true}, "set")
  end

  test "#revert restores the previous boolean value" do
    @word.update!(foreign: false)
    change = BulkEditChange.new(previous_value: {"value" => true}, applied_value: {"value" => false})
    @strategy.revert(@word, change)
    assert @word.reload.foreign
  end

  test "#display_current returns 'Ja' or 'Nein'" do
    @word.update!(foreign: true)
    assert_equal I18n.t("simple_form.yes"), @strategy.display_current(@word.reload)
    @word.update!(foreign: false)
    assert_equal I18n.t("simple_form.no"), @strategy.display_current(@word.reload)
  end

  test "#display_value formats a recorded nil value as 'none' (for legacy records)" do
    assert_equal I18n.t("bulk_edits.values.none"), @strategy.display_value({"value" => nil})
  end

  test "#missing_scope returns words with the boolean unset or false" do
    true_word = create(:noun, foreign: true)
    false_word = create(:noun, foreign: false)
    scope = @strategy.missing_scope(Word.all)

    assert_includes scope, false_word
    refute_includes scope, true_word
  end
end
