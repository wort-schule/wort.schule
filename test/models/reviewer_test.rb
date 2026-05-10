# frozen_string_literal: true

require "test_helper"

class ReviewerTest < ActiveSupport::TestCase
  setup do
    @me = create(:user)
    @other_user = create(:user)
    @different_user = create(:user)

    @reviewable_skipped_by_other = create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.reviews.create!(reviewer: @other_user, state: :skipped)
    end
    @reviewable_fully_confirmed = create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :confirmed)
      reviewable.change_group.reviews.create!(reviewer: @other_user, state: :confirmed)
      reviewable.change_group.reviews.create!(reviewer: @different_user, state: :confirmed)
    end
    @reviewable_edited = create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :edited, successor: @reviewable_skipped_by_other.change_group)
      reviewable.change_group.reviews.create!(reviewer: @me, state: :edited)
    end
    @reviewable_origin_edited = create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :waiting_for_review)
      reviewable.change_group.reviews.create!(reviewer: @other_user, state: :edited)
    end
    @reviewable_origin = create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(successor: @reviewable_origin_edited.change_group)
      reviewable.change_group.reviews.create!(reviewer: @me, state: :confirmed)
    end
  end

  test "includes only direct reviews, not parent reviews" do
    user_ids = {
      @me.id => :me,
      @other_user.id => :other_user,
      @different_user.id => :different_user
    }
    reviewable_ids = {
      @reviewable_skipped_by_other.change_group_id => :reviewable_skipped_by_other,
      @reviewable_fully_confirmed.change_group_id => :reviewable_fully_confirmed,
      @reviewable_edited.change_group_id => :reviewable_edited,
      @reviewable_origin.change_group_id => :reviewable_origin,
      @reviewable_origin_edited.change_group_id => :reviewable_origin_edited
    }

    symbols = Reviewer.all.pluck(:change_group_id, :reviewer_id).map do |reviewable_id, user_id|
      [
        reviewable_ids[reviewable_id],
        user_ids[user_id]
      ]
    end

    expected = [
      [:reviewable_skipped_by_other, :other_user],
      [:reviewable_fully_confirmed, :other_user],
      [:reviewable_fully_confirmed, :different_user],
      [:reviewable_edited, :me],
      [:reviewable_origin, :me],
      [:reviewable_origin_edited, :other_user]
    ]

    assert_equal expected.sort, symbols.sort
  end
end
