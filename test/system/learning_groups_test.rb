# frozen_string_literal: true

require "application_system_test_case"

class LearningGroupsTest < ApplicationSystemTestCase
  test "as a lecturer activates invitations" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    login_as lecturer

    old_token = learning_group.invitation_token
    assert_equal false, learning_group.invitable

    visit learning_group_path(learning_group)

    click_on t("learning_groups.invitation.activate")
    assert_text t("learning_groups.invitation.active")

    learning_group.reload
    assert learning_group.invitation_token.present?
    refute_equal old_token, learning_group.invitation_token
    assert_equal true, learning_group.invitable
  end

  test "as a lecturer deactivates invitations with active invitations" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer, invitable: true)
    login_as lecturer

    assert_equal true, learning_group.invitable

    visit learning_group_path(learning_group)

    click_on t("learning_groups.invitation.deactivate")
    assert_text t("learning_groups.invitation.activate")

    learning_group.reload
    assert_nil learning_group.invitation_token
    assert_equal false, learning_group.invitable
  end

  test "as a lecturer invites a user by email address" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    login_as lecturer

    new_user = create(:user)

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_user")

    fill_in LearningGroupMembership.human_attribute_name(:user), with: new_user.email
    assert_difference -> { learning_group.learning_group_memberships.count }, +1 do
      click_on t("learning_group_memberships.new.assign")
    end

    assert_current_path learning_group_path(learning_group)
    assert_equal "invited", learning_group.learning_group_memberships.find_by(user: new_user).access
    assert_text new_user.full_name
    assert_includes new_user.reload.learning_groups, learning_group

    login_as new_user
    visit profile_path
    within "#learning_groups" do
      assert_text learning_group.name

      click_on t("profiles.show.accept")
      assert_equal "granted", learning_group.learning_group_memberships.find_by(user: new_user).access
    end
  end

  test "as a lecturer invites a user by username" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    login_as lecturer

    username = "abcd"
    new_user = create(:user, email: "#{username}@user.wort.schule")

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_user")

    fill_in LearningGroupMembership.human_attribute_name(:user), with: username
    assert_difference -> { learning_group.learning_group_memberships.count }, +1 do
      click_on t("learning_group_memberships.new.assign")
    end

    assert_current_path learning_group_path(learning_group)
    assert_equal "invited", learning_group.learning_group_memberships.find_by(user: new_user).access
    assert_text new_user.full_name
  end

  test "as a lecturer does not invite a user already in the learning group" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    login_as lecturer

    user = create(:user)
    learning_group.learning_group_memberships.create(user:, access: :granted)

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_user")

    fill_in LearningGroupMembership.human_attribute_name(:user), with: user.email
    assert_no_difference -> { learning_group.learning_group_memberships.count } do
      click_on t("learning_group_memberships.new.assign")
    end

    assert_text t("errors.messages.taken")
  end

  test "as a lecturer adds a word list" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    login_as lecturer

    word_list = create(:list, user: lecturer, visibility: :public)

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")

    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a
  end

  test "as a user accepts an invitation" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer, invitable: true)
    user = create(:guest)

    refute_includes learning_group.users, user

    login_as lecturer
    visit learning_group_path(learning_group)

    url = find('input[name="invitation_url"]').value

    login_as user
    visit url

    assert_text learning_group.name
    learning_group.reload
    assert_includes learning_group.users, user
  end
end

# The request_access and accept actions are rendered as `link_to ..., method: :post`.
# Cuprite (a real browser) cannot intercept those without rails-ujs; rack_test fakes
# the POST natively. Run this flow under rack_test to mirror the original feature
# spec's default driver.
class LearningGroupsAccessRequestTest < ApplicationSystemTestCase
  driven_by :rack_test

  test "as a user requests access" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer, invitable: true)
    user = create(:guest)

    login_as user
    visit learning_groups_path
    click_on learning_group.name

    assert_difference -> { LearningGroupMembership.count }, +1 do
      click_on t("learning_groups.show.request_access")
    end

    assert_text t("notices.learning_group_memberships.access_requested")
    membership = LearningGroupMembership.last
    assert_equal learning_group, membership.learning_group
    assert_equal user, membership.user
    assert_equal "requested", membership.access

    login_as lecturer
    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.accept")

    membership.reload
    assert_equal "granted", membership.access
  end
end
