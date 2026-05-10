# frozen_string_literal: true

require "test_helper"
require "rake"

class ChangeGroupReviewsTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["change_groups:process_waiting_reviews"].reenable
  end

  test "processes change groups with sufficient confirmed reviews" do
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group
    change_group.reviews.create!(reviewer: create(:user), state: :confirmed)

    assert_equal "waiting_for_review", change_group.reload.state
    assert_equal 1, change_group.confirmed_review_count

    Rake::Task["change_groups:process_waiting_reviews"].invoke

    assert_equal "confirmed", change_group.reload.state
  end

  test "skips change groups without sufficient confirmed reviews" do
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group

    assert_equal "waiting_for_review", change_group.reload.state
    assert_equal 0, change_group.confirmed_review_count

    Rake::Task["change_groups:process_waiting_reviews"].invoke

    assert_equal "waiting_for_review", change_group.reload.state
  end

  test "skips change groups that are already confirmed" do
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group
    change_group.update!(state: :confirmed)

    assert_equal "confirmed", change_group.reload.state

    Rake::Task["change_groups:process_waiting_reviews"].invoke

    assert_equal "confirmed", change_group.reload.state
  end

  test "processes multiple qualifying change groups" do
    word_attribute_edit1 = create(:word_attribute_edit)
    change_group1 = word_attribute_edit1.change_group
    change_group1.reviews.create!(reviewer: create(:user), state: :confirmed)

    word_attribute_edit2 = create(:word_attribute_edit)
    change_group2 = word_attribute_edit2.change_group
    change_group2.reviews.create!(reviewer: create(:user), state: :confirmed)

    assert_equal "waiting_for_review", change_group1.reload.state
    assert_equal "waiting_for_review", change_group2.reload.state

    Rake::Task["change_groups:process_waiting_reviews"].invoke

    assert_equal "confirmed", change_group1.reload.state
    assert_equal "confirmed", change_group2.reload.state
  end
end
