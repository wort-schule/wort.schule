# frozen_string_literal: true

require "application_system_test_case"

class LecturerRoleTest < ApplicationSystemTestCase
  setup do
    @lecturer = create(:lecturer)
    login_as @lecturer
  end

  test "without groups, creates a group" do
    visit root_path
    visit navigation_path
    click_on LearningGroup.model_name.human(count: 2), match: :first

    click_on t("learning_groups.index.new")

    fill_in LearningGroup.human_attribute_name(:name), with: "Sommercamp"

    assert_difference -> { LearningGroup.count }, +1 do
      click_on t("helpers.submit.create")
    end

    learning_group = LearningGroup.last
    assert_equal "Sommercamp", learning_group.name
    assert_equal @lecturer, learning_group.owner
  end

  test "with an existing group, edits a group" do
    learning_group = create(:learning_group, owner: @lecturer)
    new_name = "Neuer Gruppenname"

    visit learning_groups_path

    refute_equal new_name, learning_group.name

    click_on learning_group.name

    click_on t("actions.edit")
    fill_in LearningGroup.human_attribute_name(:name), with: new_name

    click_on t("helpers.submit.update")
    learning_group.reload
    assert_equal new_name, learning_group.name
  end

  test "with an existing group, deletes a group" do
    learning_group = create(:learning_group, owner: @lecturer)

    visit learning_groups_path

    click_on learning_group.name
    click_on t("actions.edit")

    assert_difference -> { LearningGroup.count }, -1 do
      click_on t("actions.delete")
    end

    assert_raises ActiveRecord::RecordNotFound do
      learning_group.reload
    end
  end

  test "with users, when a user is a member, removes a user" do
    learning_group = create(:learning_group, owner: @lecturer)
    user = create(:guest)
    create(:learning_group_membership, learning_group:, user:, access: "granted")

    visit learning_groups_path
    click_on learning_group.name

    assert_difference -> { LearningGroupMembership.count }, -1 do
      within "##{dom_id(user)}" do
        click_on t("actions.remove")
      end
    end

    refute_includes user.learning_groups, learning_group
    refute_includes learning_group.users, user
  end
end
