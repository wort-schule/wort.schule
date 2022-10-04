# frozen_string_literal: true

RSpec.describe "sign in" do
  let!(:user) { create :user }
  let(:flow) { Flows::Signin.new }

  it "shows login form on root path" do
    visit root_path
    expect(page).to have_content t("devise.sessions.new.sign_in")
  end

  it "signs in and signs out", js: true do
    visit new_user_session_path

    flow.sign_in(email: user.email, password: user.password)
    expect(page).to have_current_path root_path

    find("#user-menu-button").click
    click_on t("navigation.logout")

    expect(page).to have_content t("devise.sessions.new.sign_in")
  end
end
