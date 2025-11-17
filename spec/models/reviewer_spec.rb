# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reviewer do
  subject { Reviewer.all }

  let(:me) { create(:user) }
  let(:other_user) { create(:user) }
  let(:different_user) { create(:user) }
  let!(:reviewable_skipped_by_other) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.reviews.create!(reviewer: other_user, state: :skipped)
    end
  end
  let!(:reviewable_fully_confirmed) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :confirmed)
      reviewable.change_group.reviews.create!(reviewer: other_user, state: :confirmed)
      reviewable.change_group.reviews.create!(reviewer: different_user, state: :confirmed)
    end
  end
  let!(:reviewable_edited) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :edited, successor: reviewable_skipped_by_other.change_group)
      reviewable.change_group.reviews.create!(reviewer: me, state: :edited)
    end
  end
  let!(:reviewable_origin) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(successor: reviewable_origin_edited.change_group)
      reviewable.change_group.reviews.create!(reviewer: me, state: :confirmed)
    end
  end
  let!(:reviewable_origin_edited) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.change_group.update!(state: :waiting_for_review)
      reviewable.change_group.reviews.create!(reviewer: other_user, state: :edited)
    end
  end

  it "includes only direct reviews, not parent reviews" do
    user_ids = {
      me.id => :me,
      other_user.id => :other_user,
      different_user.id => :different_user
    }
    reviewable_ids = {
      reviewable_skipped_by_other.change_group_id => :reviewable_skipped_by_other,
      reviewable_fully_confirmed.change_group_id => :reviewable_fully_confirmed,
      reviewable_edited.change_group_id => :reviewable_edited,
      reviewable_origin.change_group_id => :reviewable_origin,
      reviewable_origin_edited.change_group_id => :reviewable_origin_edited
    }

    symbols = subject.pluck(:change_group_id, :reviewer_id).map do |reviewable_id, user_id|
      [
        reviewable_ids[reviewable_id],
        user_ids[user_id]
      ]
    end

    # Only direct reviews should be included, not reviews of predecessors
    expect(symbols).to match_array [
      [:reviewable_skipped_by_other, :other_user],
      [:reviewable_fully_confirmed, :other_user],
      [:reviewable_fully_confirmed, :different_user],
      [:reviewable_edited, :me],
      [:reviewable_origin, :me],
      [:reviewable_origin_edited, :other_user]
    ]
  end
end
