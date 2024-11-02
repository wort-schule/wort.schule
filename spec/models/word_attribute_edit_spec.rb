# frozen_string_literal: true

RSpec.describe WordAttributeEdit do
  describe ".reviewable" do
    subject { described_class.reviewable(me.id) }

    let(:me) { create(:user) }
    let(:other_user) { create(:user) }
    let(:different_user) { create(:user) }
    let!(:reviewable_without_reviews) { create(:word_attribute_edit) }
    let!(:reviewable_skipped_by_other) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.reviews.create!(reviewer: other_user, state: :skipped)
      end
    end
    let!(:reviewable_confirmed_by_other) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.reviews.create!(reviewer: other_user, state: :confirmed)
      end
    end
    let!(:reviewable_skipped_by_me) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.reviews.create!(reviewer: me, state: :skipped)
      end
    end
    let!(:reviewable_confirmed_by_me) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.reviews.create!(reviewer: me, state: :confirmed)
      end
    end
    let!(:reviewable_fully_confirmed) do
      create(:word_attribute_edit, state: :confirmed).tap do |reviewable|
        reviewable.reviews.create!(reviewer: other_user, state: :confirmed)
        reviewable.reviews.create!(reviewer: different_user, state: :confirmed)
      end
    end
    let!(:reviewable_successor) { create(:word_attribute_edit, state: :waiting_for_review) }
    let!(:reviewable_edited) do
      create(:word_attribute_edit, state: :edited, successor: reviewable_successor).tap do |reviewable|
        reviewable.reviews.create!(reviewer: me, state: :edited)
      end
    end

    it "returns the correct reviewables" do
      expect(reviewable_without_reviews.confirmed_review_count).to eq 0
      expect(reviewable_skipped_by_other.confirmed_review_count).to eq 0
      expect(reviewable_confirmed_by_other.confirmed_review_count).to eq 1
      expect(reviewable_skipped_by_me.confirmed_review_count).to eq 0
      expect(reviewable_confirmed_by_me.confirmed_review_count).to eq 1
      expect(reviewable_fully_confirmed.confirmed_review_count).to eq 2
      expect(reviewable_successor.confirmed_review_count).to eq 0
      expect(reviewable_edited.confirmed_review_count).to eq 0

      ids = {
        reviewable_without_reviews.id => :reviewable_without_reviews,
        reviewable_skipped_by_other.id => :reviewable_skipped_by_other,
        reviewable_confirmed_by_other.id => :reviewable_confirmed_by_other,
        reviewable_skipped_by_me.id => :reviewable_skipped_by_me,
        reviewable_confirmed_by_me.id => :reviewable_confirmed_by_me,
        reviewable_fully_confirmed.id => :reviewable_fully_confirmed,
        reviewable_successor.id => :reviewable_successor,
        reviewable_edited.id => :reviewable_edited
      }

      symbols = subject.pluck(:id).map { |id| ids[id] }

      expect(symbols).to match_array [
        :reviewable_without_reviews,
        :reviewable_skipped_by_other,
        :reviewable_confirmed_by_other
      ]
    end
  end

  describe "#store_review" do
    subject { reviewable.store_review(reviewer:, state:) }

    let(:reviewable) { create(:word_attribute_edit) }

    it "completes the review with enough reviews" do
      reviewable.store_review(reviewer: create(:user), state: :skipped)
      expect(reviewable.state).to eq "waiting_for_review"

      reviewable.store_review(reviewer: create(:user), state: :confirmed)
      expect(reviewable.state).to eq "waiting_for_review"

      reviewable.store_review(reviewer: create(:user), state: :confirmed)
      expect(reviewable.state).to eq "confirmed"
    end
  end
end
