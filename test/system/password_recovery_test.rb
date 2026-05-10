# frozen_string_literal: true

require "application_system_test_case"

class PasswordRecoveryTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    @new_password = "new-password-123"
  end

  test "resets the password" do
    refute @user.valid_password?(@new_password)

    visit user_session_path
    click_on t("devise.shared.links.forgot_your_password")

    fill_in User.human_attribute_name(:email), with: @user.email
    click_on t("devise.passwords.new.send_me_reset_password_instructions")

    assert_text t("devise.passwords.send_paranoid_instructions")

    reset_email = emails_by_subject(t("devise.mailer.reset_password_instructions.subject")).first
    reset_link = link_with_text(reset_email, t("devise.mailer.reset_password_instructions.action"))

    # Mailer renders absolute URLs against the mailer host (localhost:3000),
    # but Capybara serves on a random port. Strip to a path so the visit
    # lands on the Capybara session.
    reset_uri = URI.parse(reset_link)
    visit "#{reset_uri.path}?#{reset_uri.query}"

    fill_in t("devise.passwords.edit.new_password"), match: :first, with: @new_password
    fill_in t("devise.passwords.edit.confirm_new_password"), with: @new_password
    click_on t("devise.passwords.edit.change_my_password")

    @user.reload
    assert @user.valid_password?(@new_password)
  end

  test "does not expose whether users have an account" do
    visit user_session_path
    click_on t("devise.shared.links.forgot_your_password")

    fill_in User.human_attribute_name(:email), with: "invalid-user@example.com"

    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      click_on t("devise.passwords.new.send_me_reset_password_instructions")
    end

    assert_text t("devise.passwords.send_paranoid_instructions")
  end
end
