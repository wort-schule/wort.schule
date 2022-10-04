# frozen_string_literal: true

RSpec.describe "password recovery" do
  let!(:user) { create :user }
  let(:new_password) { "new-password-123" }

  it "resets the password" do
    expect(user.valid_password?(new_password)).to be false

    visit user_session_path
    click_on t("devise.shared.links.forgot_your_password")

    fill_in User.human_attribute_name(:email), with: user.email
    click_on t("devise.passwords.new.send_me_reset_password_instructions")

    expect(page).to have_content t("devise.passwords.send_paranoid_instructions")

    reset_email = emails_by_subject(t("devise.mailer.reset_password_instructions.subject")).first
    reset_link = link_with_text(reset_email, t("devise.mailer.reset_password_instructions.action"))

    visit reset_link

    fill_in t("devise.passwords.edit.new_password"), match: :first, with: new_password
    fill_in t("devise.passwords.edit.confirm_new_password"), with: new_password
    click_on t("devise.passwords.edit.change_my_password")

    user.reload
    expect(user.valid_password?(new_password)).to be true
  end

  it "does not expose whether users have an account" do
    visit user_session_path
    click_on t("devise.shared.links.forgot_your_password")

    fill_in User.human_attribute_name(:email), with: "invalid-user@example.com"

    expect do
      click_on t("devise.passwords.new.send_me_reset_password_instructions")
    end.not_to change(ActionMailer::Base.deliveries, :count)

    expect(page).to have_content t("devise.passwords.send_paranoid_instructions")
  end
end
