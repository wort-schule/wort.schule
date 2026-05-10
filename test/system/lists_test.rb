# frozen_string_literal: true

require "application_system_test_case"

class ListsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:admin)
    login_as @admin
  end

  test "shows existing lists" do
    list = create(:list, user: @admin)

    visit lists_path

    assert_text list.name
  end

  test "edits an list" do
    list = create(:list, user: @admin)

    visit lists_path

    click_on list.name
    click_on t("actions.edit")
    fill_in "list[name]", with: "Anderer Name"
    click_on t("helpers.submit.update")

    list.reload
    assert_equal "Anderer Name", list.name
  end

  test "shows an error when invalid on update" do
    list = create(:list, user: @admin)

    visit lists_path

    click_on list.name
    click_on t("actions.edit")
    fill_in "list[name]", with: ""

    assert_no_difference -> { List.count } do
      click_on t("helpers.submit.update")
    end

    assert_text t("errors.messages.blank")
  end

  test "deletes an list" do
    list = create(:list, user: @admin)

    visit lists_path

    click_on list.name
    click_on t("actions.edit")
    click_on t("actions.delete")

    assert_raises ActiveRecord::RecordNotFound do
      list.reload
    end
  end

  test "adds a word to a list" do
    list = create(:list, user: @admin)
    noun = create(:noun, name: "Adler")

    visit noun_path(noun)

    select list.name
    click_on I18n.t("words.show.lists.add")

    assert_equal [noun], list.words
  end

  test "removes a word from a a list" do
    list = create(:list, user: @admin)
    noun = create(:noun, name: "Adler")

    visit noun_path(noun)
    select list.name
    click_on I18n.t("words.show.lists.add")
    assert_equal [noun], list.words

    visit list_path(list)
    click_on I18n.t("actions.remove")

    assert_equal [], list.reload.words
  end

  test "creates an list" do
    visit lists_path
    click_on t("lists.index.new")

    fill_in "list[name]", with: "Neuer Name"

    assert_difference -> { List.count }, +1 do
      click_on t("helpers.submit.create")
    end

    assert_equal "Neuer Name", List.last.name
  end

  test "shows an error when invalid on create" do
    visit lists_path
    click_on t("lists.index.new")

    assert_no_difference -> { List.count } do
      click_on t("helpers.submit.create")
    end

    assert_text t("errors.messages.blank")
  end
end
