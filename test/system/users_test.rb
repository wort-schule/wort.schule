# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "as an admin, creates a user" do
    admin = create(:user, role: "Admin")
    login_as admin
    visit root_path

    visit navigation_path
    click_on User.model_name.human(count: 2)

    click_on t("users.index.new")

    fill_in User.human_attribute_name(:first_name), with: "Sarah"
    fill_in User.human_attribute_name(:last_name), with: "Muster"
    fill_in User.human_attribute_name(:email), with: "muster@example.com"
    select t("enumerize.user.role.Admin"), from: User.human_attribute_name(:role)

    assert_difference -> { User.count }, +1 do
      click_on t("helpers.submit.create")
    end

    user = User.find_by(email: "muster@example.com")
    assert_equal "Sarah", user.first_name
    assert_equal "Muster", user.last_name
    assert_equal "muster@example.com", user.email
    assert_equal "Admin", user.role
  end

  test "as an admin, shows all users" do
    admin = create(:user, role: "Admin")
    user = create(:user, first_name: "Sarah")
    login_as admin
    visit root_path

    visit navigation_path
    click_on User.model_name.human(count: 2)

    assert_selector "h1", text: User.model_name.human(count: 2)
    assert_text user.full_name
  end

  test "as an admin, edits a user" do
    admin = create(:user, role: "Admin")
    user = create(:user, first_name: "Sarah")
    login_as admin
    visit root_path

    assert_equal "Sarah", user.first_name

    visit navigation_path
    click_on User.model_name.human(count: 2)

    assert_selector "h1", text: User.model_name.human(count: 2)
    find("##{dom_id(user)}").click

    click_on t("actions.edit")

    fill_in User.human_attribute_name(:first_name), with: "Tom"
    click_on t("helpers.submit.update")

    user.reload
    assert_equal "Tom", user.first_name
  end

  test "as an admin, deletes a user" do
    admin = create(:user, role: "Admin")
    user = create(:user, first_name: "Sarah")
    login_as admin
    visit root_path

    visit navigation_path
    click_on User.model_name.human(count: 2)

    assert_selector "h1", text: User.model_name.human(count: 2)
    find("##{dom_id(user)}").click

    click_on t("actions.edit")

    assert_difference -> { User.count }, -1 do
      click_on t("actions.delete")
    end
  end

  test "when not logged in, cannot access users page" do
    visit users_path

    assert_no_current_path users_path
    assert_no_selector "h1", text: User.model_name.human(count: 2)
  end

  test "as a guest, cannot access users page" do
    guest = create(:user, role: "Guest")
    login_as guest

    assert_raises CanCan::AccessDenied do
      visit users_path
    end
  end
end
