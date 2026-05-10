# frozen_string_literal: true

require "application_system_test_case"

class ProfileTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    login_as @user
  end

  test "allows to upload an avatar" do
    refute @user.avatar.attached?

    visit profile_path
    assert_selector "img[src*='//www.gravatar.com/avatar']"
    within ".ci-avatar" do
      click_on t("actions.change")
    end

    attach_file User.human_attribute_name(:avatar), Rails.root.join("test/fixtures/files/avatar1.png").to_s
    click_on t("helpers.submit.update")

    @user.reload
    assert @user.avatar.attached?
  end

  test "deletes an existing avatar" do
    @user.update!(
      avatar: ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(File.read(Rails.root.join("test/fixtures/files/avatar1.png").to_s)),
        filename: "avatar1.png"
      )
    )
    assert @user.avatar.attached?

    visit profile_path
    click_on t("actions.delete")

    @user.reload
    refute @user.avatar.attached?
  end

  test "changes the password" do
    old_password = @user.password
    new_password = "new-password-123"
    flow = Flows::Profile.new

    assert @user.valid_password?(old_password)

    visit profile_path
    within ".ci-password" do
      click_on t("actions.change")
    end

    flow.change_password(old_password:, new_password:)

    @user.reload
    refute @user.valid_password?(old_password)
    assert @user.valid_password?(new_password)
  end

  test "shows an error on invalid password when changing the password" do
    old_password = @user.password
    new_password = "new-password-123"
    flow = Flows::Profile.new

    assert @user.valid_password?(old_password)

    visit profile_path
    within ".ci-password" do
      click_on t("actions.change")
    end

    flow.change_password(old_password: "invalid", new_password:)

    @user.reload
    assert @user.valid_password?(old_password)
    refute @user.valid_password?(new_password)

    flow.change_password(old_password:, new_password:)

    @user.reload
    refute @user.valid_password?(old_password)
    assert @user.valid_password?(new_password)
  end

  test "changes the email address" do
    new_email = "new-email@example.com"
    flow = Flows::Profile.new

    refute_equal new_email, @user.email

    visit profile_path
    within ".ci-email" do
      click_on t("actions.change")
    end

    flow.change_email(new_email:, current_password: @user.password)

    @user.reload
    @user.confirm
    assert_equal new_email, @user.email
  end

  test "shows an error on invalid password when changing the email" do
    new_email = "new-email@example.com"
    flow = Flows::Profile.new

    refute_equal new_email, @user.email

    visit profile_path
    within ".ci-email" do
      click_on t("actions.change")
    end

    flow.change_email(new_email:, current_password: "invalid")

    @user.reload
    refute_equal new_email, @user.email

    flow.change_email(new_email:, current_password: @user.password)

    @user.reload
    @user.confirm
    assert_equal new_email, @user.email
  end
end
