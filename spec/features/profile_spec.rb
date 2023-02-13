# frozen_string_literal: true

RSpec.describe "user profile" do
  let(:user) { create :user }

  before do
    login_as user
  end

  describe "avatar" do
    it "allows to upload an avatar" do
      expect(user.avatar).not_to be_attached

      visit profile_path
      expect(page).to have_css "img[src*='//www.gravatar.com/avatar']"
      within ".ci-avatar" do
        click_on t("actions.change")
      end

      attach_file User.human_attribute_name(:avatar), Rails.root.join("spec/fixtures/files/avatar1.png")
      click_on t("helpers.submit.update")

      user.reload
      expect(user.avatar).to be_attached
    end

    context "with an existing avatar" do
      before do
        user.update!(
          avatar: ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new(File.read("spec/fixtures/files/avatar1.png")),
            filename: "avatar1.png"
          )
        )
      end

      it "deletes the avatar" do
        expect(user.avatar).to be_attached

        visit profile_path
        click_on t("actions.delete")

        user.reload
        expect(user.avatar).not_to be_attached
      end
    end
  end

  describe "password" do
    let(:old_password) { user.password }
    let(:new_password) { "new-password-123" }
    let(:flow) { Flows::Profile.new }

    before do
      expect(user.valid_password?(old_password)).to be true

      visit profile_path
      within ".ci-password" do
        click_on t("actions.change")
      end
    end

    it "changes the password" do
      flow.change_password(old_password:, new_password:)

      user.reload
      expect(user.valid_password?(old_password)).to be false
      expect(user.valid_password?(new_password)).to be true
    end

    it "shows an error on invalid password" do
      flow.change_password(old_password: "invalid", new_password:)

      user.reload
      expect(user.valid_password?(old_password)).to be true
      expect(user.valid_password?(new_password)).to be false

      # Try again with the right password
      flow.change_password(old_password:, new_password:)

      user.reload
      expect(user.valid_password?(old_password)).to be false
      expect(user.valid_password?(new_password)).to be true
    end
  end

  describe "email" do
    let(:new_email) { "new-email@example.com" }
    let(:flow) { Flows::Profile.new }

    before do
      expect(user.email).not_to eq new_email

      visit profile_path
      within ".ci-email" do
        click_on t("actions.change")
      end
    end

    it "changes the email address" do
      flow.change_email(new_email:, current_password: user.password)

      user.reload
      user.confirm
      expect(user.email).to eq new_email
    end

    it "shows an error on invalid password" do
      flow.change_email(new_email:, current_password: "invalid")

      user.reload
      expect(user.email).not_to eq new_email

      # Try again with the right password
      flow.change_email(new_email:, current_password: user.password)

      user.reload
      user.confirm
      expect(user.email).to eq new_email
    end
  end
end
