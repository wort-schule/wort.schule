# frozen_string_literal: true

require "application_system_test_case"

class FriendlyIdTest < ApplicationSystemTestCase
  test "allows to edit a slug" do
    noun = create(:noun, name: "Ticken")
    verb = create(:noun, name: "ticken")
    admin = create(:user, role: "Admin")
    login_as admin

    assert_equal "ticken", noun.slug
    assert_equal "ticken-2", verb.slug

    visit edit_verb_path(verb)
    assert_field t("activerecord.attributes.word.slug"), with: "ticken-2"
    fill_in t("activerecord.attributes.word.slug"), with: "ticken-verb"
    click_on t("helpers.submit.update")

    assert_equal "ticken-verb", verb.reload.slug
  end
end
