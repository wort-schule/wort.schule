# frozen_string_literal: true

RSpec.describe "users" do
  context "when logged in as an admin" do
    let(:admin) { create :user, role: "Admin" }

    before do
      login_as admin
      visit root_path
    end

    it "creates a user" do
      within ".ci-navigation" do
        click_on User.model_name.human(count: 2)
      end

      click_on t("users.index.new")

      fill_in User.human_attribute_name(:first_name), with: "Sarah"
      fill_in User.human_attribute_name(:last_name), with: "Muster"
      fill_in User.human_attribute_name(:email), with: "muster@example.com"
      select t("enumerize.user.role.Admin"), from: User.human_attribute_name(:role)

      expect do
        click_on t("helpers.submit.create")
      end.to change(User, :count).by(1)

      user = User.find_by(email: "muster@example.com")
      expect(user.first_name).to eq "Sarah"
      expect(user.last_name).to eq "Muster"
      expect(user.email).to eq "muster@example.com"
      expect(user.role).to eq "Admin"
    end

    context "with an existing user" do
      let!(:user) { create :user, first_name: "Sarah" }

      it "shows all users" do
        within ".ci-navigation" do
          click_on User.model_name.human(count: 2)
        end

        expect(page).to have_selector "h1", text: User.model_name.human(count: 2)
        expect(page).to have_content user.full_name
      end

      it "edits a user" do
        expect(user.first_name).to eq "Sarah"

        within ".ci-navigation" do
          click_on User.model_name.human(count: 2)
        end

        expect(page).to have_selector "h1", text: User.model_name.human(count: 2)
        find("##{dom_id(user)}").click

        click_on t("actions.edit")

        fill_in User.human_attribute_name(:first_name), with: "Tom"
        click_on t("helpers.submit.update")

        user.reload
        expect(user.first_name).to eq "Tom"
      end

      it "deletes a user" do
        within ".ci-navigation" do
          click_on User.model_name.human(count: 2)
        end

        expect(page).to have_selector "h1", text: User.model_name.human(count: 2)
        find("##{dom_id(user)}").click

        click_on t("actions.edit")

        expect do
          click_on t("actions.delete")
        end.to change(User, :count).by(-1)
      end
    end
  end

  context "when not logged in" do
    before do
      logout
    end

    it "cannot access users page" do
      visit users_path

      expect(page).not_to have_current_path users_path
      expect(page).not_to have_selector "h1", text: User.model_name.human(count: 2)
    end
  end

  context "when logged in as a guest" do
    let(:guest) { create :user, role: "Guest" }

    before do
      login_as guest
    end

    it "cannot access users page" do
      expect do
        visit users_path
      end.to raise_error CanCan::AccessDenied
    end
  end
end
