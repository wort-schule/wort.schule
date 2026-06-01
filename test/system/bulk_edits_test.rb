# frozen_string_literal: true

require "application_system_test_case"

class BulkEditsTest < ApplicationSystemTestCase
  test "admin finds words by wildcard search" do
    admin = create(:admin)
    create(:noun, name: "Haustier")
    create(:noun, name: "Hausboot")
    create(:noun, name: "Schule")

    login_as admin
    visit bulk_edits_path
    fill_in "q", with: "Haus*"
    click_on I18n.t("bulk_edits.index.search_button")

    assert_text "Haustier"
    assert_text "Hausboot"
    assert_no_text "Schule"
  end

  test "applying a bulk edit creates a protocol entry" do
    admin = create(:admin)
    noun = create(:noun, name: "Haus")
    phenomenon = create(:phenomenon, name: "Doppelkonsonanz")

    BulkEditService.new(user: admin).execute(
      word_ids: [noun.id],
      field: "phenomenons",
      operation: "add",
      value: {"ids" => [phenomenon.id]},
      search_query: "Haus*"
    )

    login_as admin
    visit bulk_edits_path
    assert_text I18n.t("bulk_edits.index.tab_log")
  end

  test "lecturer can reach the page but cannot undo other users' entries" do
    admin = create(:admin)
    lecturer = create(:lecturer)
    noun = create(:noun, name: "Haus")
    phenomenon = create(:phenomenon, name: "P")

    admin_edit = BulkEditService.new(user: admin).execute(
      word_ids: [noun.id], field: "phenomenons", operation: "add", value: {"ids" => [phenomenon.id]}
    )

    login_as lecturer
    visit bulk_edits_path

    assert_text I18n.t("bulk_edits.index.title")
    refute admin_edit.undoable_by?(lecturer)
    assert admin_edit.undoable_by?(admin)
  end

  test "deselecting a single word after selecting all matches keeps the rest selected" do
    admin = create(:admin)
    create(:noun, name: "Hausboot")
    create(:noun, name: "Haustier")
    create(:noun, name: "Hausschuh")

    login_as admin
    visit bulk_edits_path
    fill_in "q", with: "Haus*"
    click_on I18n.t("bulk_edits.index.search_button")
    assert_text "Hausschuh"

    click_on I18n.t("bulk_edits.index.select_all_matches", count: 3)
    assert_text I18n.t("bulk_edits.index.count_selected", count: 3)

    # The checkbox must stay interactive: unchecking one cancels "all matches" mode
    # and falls back to an explicit selection of the rest of the page.
    deselected = Word.find_by!(name: "Haustier")
    find("input[type=checkbox][data-word-id='#{deselected.id}']").click

    assert_text I18n.t("bulk_edits.index.count_selected", count: 2)
  end

  test "denies access to guests" do
    login_as create(:guest)
    assert_raises(CanCan::AccessDenied) { visit bulk_edits_path }
  end
end
