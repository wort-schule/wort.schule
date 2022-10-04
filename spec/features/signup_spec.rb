# frozen_string_literal: true

RSpec.describe "signup" do
  let(:flow) { Flows::Signup.new }
  let(:email) { "muster@example.com" }
  let(:password) { "secret123" }

  before do
    visit new_user_session_path
    click_on t("devise.shared.links.sign_up")
  end

  it "signs up without role" do
    expect do
      flow.sign_up(email:, password:)
    end.to change(User, :count).by 1

    user = User.last
    expect(user.email).to eq email
    expect(user.valid_password?(password)).to be true
    expect(user.role).to eq "Guest"
  end

  it "may fill out profile after sign up" do
    flow.sign_up(email:, password:)
    expect(page).to have_selector "h1", text: t("profiles.show.title")

    expect(page).to have_content email

    fill_in User.human_attribute_name(:first_name), with: "Sarah"
    fill_in User.human_attribute_name(:last_name), with: "Muster"
    click_on t("actions.save")

    user = User.last
    expect(user.email).to eq email
    expect(user.valid_password?(password)).to be true
    expect(user.first_name).to eq "Sarah"
    expect(user.last_name).to eq "Muster"

    expect(page).to have_selector "h2", text: t("profiles.show.title")
    expect(page).to have_content "Sarah"
    expect(page).to have_content "Muster"
  end
end
