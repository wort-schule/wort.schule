# frozen_string_literal: true

require "test_helper"

class WordAttributeEditTest < ActiveSupport::TestCase
  setup do
    @word = create(:noun)
    @change_group = create(:change_group)
  end

  test "strips the type prefix before saving" do
    edit = WordAttributeEdit.create!(
      word: @word,
      change_group: @change_group,
      attribute_name: "noun.case_1_plural",
      value: '["test"]'
    )

    assert_equal "case_1_plural", edit.attribute_name
  end

  test "handles verb prefixes" do
    verb = create(:verb)
    edit = WordAttributeEdit.create!(
      word: verb,
      change_group: @change_group,
      attribute_name: "verb.present_singular_1",
      value: '["test"]'
    )

    assert_equal "present_singular_1", edit.attribute_name
  end

  test "leaves the attribute_name unchanged when no prefix" do
    edit = WordAttributeEdit.create!(
      word: @word,
      change_group: @change_group,
      attribute_name: "case_1_plural",
      value: '["test"]'
    )

    assert_equal "case_1_plural", edit.attribute_name
  end

  test "normalizes on update" do
    edit = WordAttributeEdit.create!(
      word: @word,
      change_group: @change_group,
      attribute_name: "case_1_plural",
      value: '["test"]'
    )

    edit.update!(attribute_name: "noun.meaning")

    assert_equal "meaning", edit.attribute_name
  end
end
