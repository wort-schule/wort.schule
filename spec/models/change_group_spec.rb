# frozen_string_literal: true

RSpec.describe ChangeGroup do
  describe ".reviewable" do
    subject { described_class.reviewable(me) }

    let(:me) { create(:user, review_attributes: ["noun.case_1_plural"]) }
    let(:other_user) { create(:user, review_attributes: ["noun.case_1_plural"]) }
    let(:different_user) { create(:user, review_attributes: ["noun.case_1_plural"]) }
    let!(:reviewable_without_reviews) { create(:word_attribute_edit) }
    let!(:reviewable_with_other_attribute) { create(:word_attribute_edit, attribute_name: "meaning") }
    let!(:reviewable_skipped_by_other) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: other_user, state: :skipped)
      end
    end
    let!(:reviewable_confirmed_by_other) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: other_user, state: :confirmed)
      end
    end
    let!(:reviewable_skipped_by_me) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: me, state: :skipped)
      end
    end
    let!(:reviewable_confirmed_by_me) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: me, state: :confirmed)
      end
    end
    let!(:reviewable_fully_confirmed) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: other_user, state: :confirmed)
        reviewable.change_group.reviews.create!(reviewer: different_user, state: :confirmed)
        reviewable.change_group.update!(state: :confirmed)
      end
    end
    let!(:reviewable_successor) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :waiting_for_review)
      end
    end
    let!(:reviewable_edited) do
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :edited, successor: reviewable_successor.change_group)
        reviewable.change_group.reviews.create!(reviewer: me, state: :edited)
      end
    end

    it "returns the correct reviewables" do
      expect(reviewable_without_reviews.change_group.confirmed_review_count).to eq 0
      expect(reviewable_skipped_by_other.change_group.confirmed_review_count).to eq 0
      expect(reviewable_confirmed_by_other.change_group.confirmed_review_count).to eq 1
      expect(reviewable_skipped_by_me.change_group.confirmed_review_count).to eq 0
      expect(reviewable_confirmed_by_me.change_group.confirmed_review_count).to eq 1
      expect(reviewable_fully_confirmed.change_group.confirmed_review_count).to eq 2
      expect(reviewable_successor.change_group.confirmed_review_count).to eq 0
      expect(reviewable_edited.change_group.confirmed_review_count).to eq 0

      ids = {
        reviewable_without_reviews.change_group_id => :reviewable_without_reviews,
        reviewable_skipped_by_other.change_group_id => :reviewable_skipped_by_other,
        reviewable_confirmed_by_other.change_group_id => :reviewable_confirmed_by_other,
        reviewable_skipped_by_me.change_group_id => :reviewable_skipped_by_me,
        reviewable_confirmed_by_me.change_group_id => :reviewable_confirmed_by_me,
        reviewable_fully_confirmed.change_group_id => :reviewable_fully_confirmed,
        reviewable_successor.change_group_id => :reviewable_successor,
        reviewable_edited.change_group_id => :reviewable_edited
      }

      symbols = subject.pluck(:id).map { |id| ids[id] }

      expect(symbols).to match_array [
        :reviewable_without_reviews,
        :reviewable_skipped_by_other,
        :reviewable_confirmed_by_other,
        :reviewable_successor
      ]
    end

    it "allows reviewer to review successor after editing predecessor" do
      # Create successor with a word_attribute_edit (using default factory which has attribute_name: "case_1_plural")
      successor = create(:word_attribute_edit).change_group

      # Create predecessor that was edited by me
      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :edited, successor:)
        reviewable.change_group.reviews.create!(reviewer: me, state: :edited)
      end

      # The reviewers view should NOT include me for the successor
      # because I only edited the predecessor, I didn't confirm/skip it on the successor itself
      reviewers_for_successor = Reviewer.where(change_group_id: successor.id, reviewer_id: me.id)
      expect(reviewers_for_successor).not_to exist

      # The successor SHOULD appear in my review queue
      # because editing a predecessor should not prevent reviewing the successor
      expect(described_class.reviewable(me).pluck(:id)).to include(successor.id)
    end

    it "excludes successor from reviewer who already reviewed it directly" do
      # Create successor with a word_attribute_edit
      successor = create(:word_attribute_edit).change_group

      # Create a review directly on the successor
      successor.reviews.create!(reviewer: me, state: :skipped)

      # The reviewers view should include me for the successor
      reviewers_for_successor = Reviewer.where(change_group_id: successor.id, reviewer_id: me.id)
      expect(reviewers_for_successor).to exist

      # The successor should NOT appear in my review queue
      expect(described_class.reviewable(me).pluck(:id)).not_to include(successor.id)
    end
  end

  describe "#store_review" do
    subject { reviewable.store_review(reviewer:, state:) }

    let(:reviewable) { create(:word_attribute_edit) }

    context "when reviews_required = 1" do
      before { GlobalSetting.reviews_required = 1 }

      it "auto-confirms on first confirmed review" do
        change_group = reviewable.change_group
        expect(change_group.state).to eq "waiting_for_review"

        change_group.store_review(reviewer: create(:user), state: :confirmed)

        expect(change_group.reload.state).to eq "confirmed"
      end

      it "does not confirm on skip" do
        change_group = reviewable.change_group
        change_group.store_review(reviewer: create(:user), state: :skipped)

        expect(change_group.reload.state).to eq "waiting_for_review"
      end

      it "applies word attribute edits when confirmed" do
        word_attribute_edit = reviewable
        word = word_attribute_edit.word
        original_value = word.case_1_plural

        word_attribute_edit.update!(value: "test_value".to_json)
        change_group = word_attribute_edit.change_group

        change_group.store_review(reviewer: create(:user), state: :confirmed)

        expect(word.reload.case_1_plural).to eq "test_value"
      end
    end

    context "when reviews_required = 2" do
      before { GlobalSetting.reviews_required = 2 }

      it "does not auto-confirm on first confirmed review" do
        user1 = create(:user)
        change_group = reviewable.change_group
        expect(change_group.state).to eq "waiting_for_review"

        change_group.store_review(reviewer: user1, state: :confirmed)

        expect(change_group.reload.state).to eq "waiting_for_review"
        expect(change_group.confirmed_review_count).to eq 1
      end

      it "confirms on second confirmed review" do
        user1 = create(:user)
        user2 = create(:user)
        change_group = reviewable.change_group

        change_group.store_review(reviewer: user1, state: :confirmed)
        expect(change_group.reload.state).to eq "waiting_for_review"

        change_group.store_review(reviewer: user2, state: :confirmed)

        expect(change_group.reload.state).to eq "confirmed"
      end

      it "does not confirm with one confirmed and one skipped" do
        user1 = create(:user)
        user2 = create(:user)
        change_group = reviewable.change_group

        change_group.store_review(reviewer: user1, state: :confirmed)
        change_group.store_review(reviewer: user2, state: :skipped)

        expect(change_group.reload.state).to eq "waiting_for_review"
        expect(change_group.confirmed_review_count).to eq 1
      end
    end

    context "when reviews_required = 3" do
      before { GlobalSetting.reviews_required = 3 }

      it "requires 3 confirmed reviews" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)
        change_group = reviewable.change_group

        change_group.store_review(reviewer: user1, state: :confirmed)
        expect(change_group.reload.state).to eq "waiting_for_review"

        change_group.store_review(reviewer: user2, state: :confirmed)
        expect(change_group.reload.state).to eq "waiting_for_review"

        change_group.store_review(reviewer: user3, state: :confirmed)
        expect(change_group.reload.state).to eq "confirmed"
      end
    end
  end
end
