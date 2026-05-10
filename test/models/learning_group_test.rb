# frozen_string_literal: true

require "test_helper"

class LearningGroupTest < ActiveSupport::TestCase
  setup do
    @requested_user = create(:guest)
    @granted_user = create(:guest)
    @learning_group = create(:learning_group)
    @granted_membership = create(:learning_group_membership, user: @granted_user, learning_group: @learning_group, access: "granted")
    @requested_membership = create(:learning_group_membership, user: @requested_user, learning_group: @learning_group, access: "requested")
  end

  test "includes only granted memberships" do
    assert_includes @learning_group.users, @granted_user
    refute_includes @learning_group.users, @requested_user
  end

  test "#destroy deletes all memberships" do
    assert_equal [@learning_group], @granted_user.learning_groups
    assert_equal [@granted_user], @learning_group.users.to_a

    @learning_group.destroy

    @granted_user.reload
    assert_equal [], @granted_user.learning_groups

    assert_raises(ActiveRecord::RecordNotFound) { @learning_group.reload }
  end
end
