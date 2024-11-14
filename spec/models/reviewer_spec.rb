# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reviewer do
  subject { Reviewer.all }

  let(:me) { create(:user) }
  let(:other_user) { create(:user) }
  let(:different_user) { create(:user) }
  let!(:reviewable_skipped_by_other) do
    create(:word_attribute_edit).tap do |reviewable|
      reviewable.reviews.create!(reviewer: other_user, state: :skipped)
    end
  end
  let!(:reviewable_fully_confirmed) do
    create(:word_attribute_edit, state: :confirmed).tap do |reviewable|
      reviewable.reviews.create!(reviewer: other_user, state: :confirmed)
      reviewable.reviews.create!(reviewer: different_user, state: :confirmed)
    end
  end
  let!(:reviewable_edited) do
    create(:word_attribute_edit, state: :edited, successor: reviewable_skipped_by_other).tap do |reviewable|
      reviewable.reviews.create!(reviewer: me, state: :edited)
    end
  end
  let!(:reviewable_origin) do
    create(:word_attribute_edit, successor: reviewable_origin_edited).tap do |reviewable|
      reviewable.reviews.create!(reviewer: me, state: :confirmed)
    end
  end
  let!(:reviewable_origin_edited) do
    create(:word_attribute_edit, state: :waiting_for_review).tap do |reviewable|
      reviewable.reviews.create!(reviewer: other_user, state: :edited)
    end
  end

  it "includes reviews of parent reviews" do
    user_ids = {
      me.id => :me,
      other_user.id => :other_user,
      different_user.id => :different_user
    }
    reviewable_ids = {
      reviewable_skipped_by_other.id => :reviewable_skipped_by_other,
      reviewable_fully_confirmed.id => :reviewable_fully_confirmed,
      reviewable_edited.id => :reviewable_edited,
      reviewable_origin.id => :reviewable_origin,
      reviewable_origin_edited.id => :reviewable_origin_edited
    }

    symbols = subject.pluck(:word_attribute_edit_id, :reviewer_id).map do |reviewable_id, user_id|
      [
        reviewable_ids[reviewable_id],
        user_ids[user_id]
      ]
    end

    expect(symbols).to match_array [
      [:reviewable_skipped_by_other, :other_user],
      [:reviewable_skipped_by_other, :me],
      [:reviewable_fully_confirmed, :other_user],
      [:reviewable_fully_confirmed, :different_user],
      [:reviewable_origin_edited, :me],
      [:reviewable_origin_edited, :other_user]
    ]
  end
end
