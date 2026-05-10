# frozen_string_literal: true

require "application_system_test_case"

class SignupTest < ApplicationSystemTestCase
  setup do
    @flow = Flows::Signup.new
    @email = "muster@example.com"
    @password = "secret123"

    visit new_user_session_path
    click_on t("devise.shared.links.sign_up")
  end

  test "signs up without role" do
    assert_empty ActionMailer::Base.deliveries

    assert_difference -> { User.count }, +1 do
      @flow.sign_up(email: @email, password: @password)
    end

    user = User.last
    assert_equal @email, user.email
    assert user.valid_password?(@password)
    assert_equal "Guest", user.role
    assert ActionMailer::Base.deliveries.present?
  end

  test "may fill out profile after sign up" do
    @flow.sign_up(email: @email, password: @password)
    assert_selector "h1", text: t("profiles.show.title")

    # Email lives inside the (mobile-style) account navigation panel, which is
    # collapsed by default. Assert against full page text rather than visible.
    assert_includes page.text(:all), @email

    fill_in User.human_attribute_name(:first_name), with: "Sarah"
    fill_in User.human_attribute_name(:last_name), with: "Muster"
    click_on t("actions.save")

    user = User.last
    assert_equal @email, user.email
    assert user.valid_password?(@password)
    assert_equal "Sarah", user.first_name
    assert_equal "Muster", user.last_name

    assert_selector "h2", text: t("profiles.show.title")
    assert_text "Sarah"
    assert_text "Muster"
  end
end
