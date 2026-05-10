# frozen_string_literal: true

require "application_system_test_case"

class SigninTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    @flow = Flows::Signin.new
  end

  test "shows login form on root path" do
    visit root_path
    assert_text t("devise.sessions.new.sign_in")
  end

  test "signs in and signs out" do
    visit new_user_session_path

    @flow.sign_in(email: @user.email, password: @user.password)
    assert_current_path root_path

    find("#user-menu-button").click
    click_on t("navigation.logout")

    assert_text t("devise.sessions.new.sign_in")
  end
end
