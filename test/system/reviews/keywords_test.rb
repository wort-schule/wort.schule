# frozen_string_literal: true

require "application_system_test_case"

class ReviewsKeywordsTest < ApplicationSystemTestCase
  setup do
    @me = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @other_admin = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @word = create(:noun, name: "Haus")
  end

  test "confirms a change" do
    edit = create(:word_attribute_edit, attribute_name: "keywords", value: ["Neues Stichwort", @word.id.to_s].to_json)
    assert_empty edit.word.keywords.map(&:name)
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name
    within '[data-toggle-buttons-target="list"]' do
      assert_equal ["Neues Stichwort", @word.name].sort, page.find_all("button").map(&:text).sort

      click_on "Neues Stichwort"
      click_on @word.name
    end

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { WordImport.count }, +1 do
        click_on I18n.t("reviews.show.actions.confirm")
      end
    end

    assert_equal "confirmed", edit.reload.change_group.state
    assert_equal [@word.name], edit.word.keywords.map(&:name)
    assert_equal 1, WordImport.count
    assert_equal "Neues Stichwort", WordImport.first.name
  end

  test "adds a new keyword during review" do
    keyword = create(:noun, name: "Hase")
    edit = create(:word_attribute_edit, attribute_name: "keywords", value: ["Neues Stichwort", @word.id].to_json)
    assert_empty edit.word.keywords.map(&:name)
    refute_equal edit.proposed_value, edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text edit.word.name

    within '[data-toggle-buttons-target="list"]' do
      click_on "Neues Stichwort"
      click_on @word.name
    end

    fill_in "tomselect-1-ts-control", with: keyword.name
    within ".ts-dropdown" do
      find(:css, "[data-value=\"#{keyword.id}\"]").click
    end
    find(".ts-control input").send_keys(:escape)

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { WordImport.count }, +1 do
        click_on I18n.t("reviews.show.actions.confirm")
      end
    end

    assert_equal "confirmed", edit.reload.change_group.state
    assert_equal [@word.name, keyword.name].sort, edit.word.keywords.map(&:name).sort
    assert_equal 1, WordImport.count
    assert_equal "Neues Stichwort", WordImport.first.name
  end
end
