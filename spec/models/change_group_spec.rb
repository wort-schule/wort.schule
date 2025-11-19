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

  describe "destroying change groups" do
    around do |example|
      # Temporarily use GoodJob adapter to test job cancellation
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :good_job
      example.run
      ActiveJob::Base.queue_adapter = original_adapter
    end

    it "cancels queued EnrichWordJobs for associated words when destroying change groups" do
      # Create a word and enqueue an EnrichWordJob
      word = create(:noun)
      job = EnrichWordJob.set(wait: 1.hour).perform_later(word.id)

      # Create change groups associated with this word
      change_group = create(:word_attribute_edit, word: word).change_group

      # Verify job is queued
      queued_job = GoodJob::Job.find_by(active_job_id: job.job_id)
      expect(queued_job).not_to be_nil
      expect(queued_job.finished_at).to be_nil

      # Destroy the change group
      change_group.destroy

      # Verify the job has been discarded
      queued_job.reload
      expect(queued_job.finished_at).not_to be_nil
      expect(queued_job.error).to include("Discarded")
    end

    it "cancels multiple EnrichWordJobs when destroying multiple change groups" do
      # Create two words with jobs
      word1 = create(:noun)
      word2 = create(:verb)
      job1 = EnrichWordJob.set(wait: 1.hour).perform_later(word1.id)
      job2 = EnrichWordJob.set(wait: 1.hour).perform_later(word2.id)

      # Create change groups
      change_group1 = create(:word_attribute_edit, word: word1).change_group
      change_group2 = create(:word_attribute_edit, word: word2).change_group

      # Destroy both change groups
      ChangeGroup.where(id: [change_group1.id, change_group2.id]).destroy_all

      # Verify both jobs have been discarded
      expect(GoodJob::Job.find_by(active_job_id: job1.job_id).finished_at).not_to be_nil
      expect(GoodJob::Job.find_by(active_job_id: job2.job_id).finished_at).not_to be_nil
    end

    it "does not affect jobs for words without associated change groups being deleted" do
      # Create two words
      word_with_deletion = create(:noun)
      word_without_deletion = create(:verb)

      # Enqueue jobs for both
      job_deleted = EnrichWordJob.set(wait: 1.hour).perform_later(word_with_deletion.id)
      job_kept = EnrichWordJob.set(wait: 1.hour).perform_later(word_without_deletion.id)

      # Create change group only for first word
      change_group = create(:word_attribute_edit, word: word_with_deletion).change_group

      # Destroy only the first change group
      change_group.destroy

      # Verify only the first job was discarded
      expect(GoodJob::Job.find_by(active_job_id: job_deleted.job_id).finished_at).not_to be_nil
      expect(GoodJob::Job.find_by(active_job_id: job_kept.job_id).finished_at).to be_nil
    end
  end
end
