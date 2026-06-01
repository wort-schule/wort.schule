# frozen_string_literal: true

require "test_helper"

class ChangeGroupTest < ActiveSupport::TestCase
  class ReviewableScopeTest < ActiveSupport::TestCase
    setup do
      @me = create(:user, review_attributes: ["noun.case_1_plural"])
      @other_user = create(:user, review_attributes: ["noun.case_1_plural"])
      @different_user = create(:user, review_attributes: ["noun.case_1_plural"])

      @reviewable_without_reviews = create(:word_attribute_edit)
      @reviewable_with_other_attribute = create(:word_attribute_edit, attribute_name: "meaning")
      @reviewable_skipped_by_other = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: @other_user, state: :skipped)
      end
      @reviewable_confirmed_by_other = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: @other_user, state: :confirmed)
      end
      @reviewable_skipped_by_me = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: @me, state: :skipped)
      end
      @reviewable_confirmed_by_me = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: @me, state: :confirmed)
      end
      @reviewable_fully_confirmed = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.reviews.create!(reviewer: @other_user, state: :confirmed)
        reviewable.change_group.reviews.create!(reviewer: @different_user, state: :confirmed)
        reviewable.change_group.update!(state: :confirmed)
      end
      @reviewable_successor = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :waiting_for_review)
      end
      @reviewable_edited = create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :edited, successor: @reviewable_successor.change_group)
        reviewable.change_group.reviews.create!(reviewer: @me, state: :edited)
      end
    end

    test "returns the correct reviewables" do
      assert_equal 0, @reviewable_without_reviews.change_group.confirmed_review_count
      assert_equal 0, @reviewable_skipped_by_other.change_group.confirmed_review_count
      assert_equal 1, @reviewable_confirmed_by_other.change_group.confirmed_review_count
      assert_equal 0, @reviewable_skipped_by_me.change_group.confirmed_review_count
      assert_equal 1, @reviewable_confirmed_by_me.change_group.confirmed_review_count
      assert_equal 2, @reviewable_fully_confirmed.change_group.confirmed_review_count
      assert_equal 0, @reviewable_successor.change_group.confirmed_review_count
      assert_equal 0, @reviewable_edited.change_group.confirmed_review_count

      ids = {
        @reviewable_without_reviews.change_group_id => :reviewable_without_reviews,
        @reviewable_skipped_by_other.change_group_id => :reviewable_skipped_by_other,
        @reviewable_confirmed_by_other.change_group_id => :reviewable_confirmed_by_other,
        @reviewable_skipped_by_me.change_group_id => :reviewable_skipped_by_me,
        @reviewable_confirmed_by_me.change_group_id => :reviewable_confirmed_by_me,
        @reviewable_fully_confirmed.change_group_id => :reviewable_fully_confirmed,
        @reviewable_successor.change_group_id => :reviewable_successor,
        @reviewable_edited.change_group_id => :reviewable_edited
      }

      symbols = ChangeGroup.reviewable(@me).pluck(:id).map { |id| ids[id] }

      expected = [
        :reviewable_without_reviews,
        :reviewable_skipped_by_other,
        :reviewable_confirmed_by_other,
        :reviewable_successor
      ]
      assert_equal expected.sort, symbols.sort
    end

    test "allows reviewer to review successor after editing predecessor" do
      successor = create(:word_attribute_edit).change_group

      create(:word_attribute_edit).tap do |reviewable|
        reviewable.change_group.update!(state: :edited, successor: successor)
        reviewable.change_group.reviews.create!(reviewer: @me, state: :edited)
      end

      reviewers_for_successor = Reviewer.where(change_group_id: successor.id, reviewer_id: @me.id)
      refute reviewers_for_successor.exists?

      assert_includes ChangeGroup.reviewable(@me).pluck(:id), successor.id
    end

    test "excludes successor from reviewer who already reviewed it directly" do
      successor = create(:word_attribute_edit).change_group

      successor.reviews.create!(reviewer: @me, state: :skipped)

      reviewers_for_successor = Reviewer.where(change_group_id: successor.id, reviewer_id: @me.id)
      assert reviewers_for_successor.exists?

      refute_includes ChangeGroup.reviewable(@me).pluck(:id), successor.id
    end
  end

  class NewWordFilterTest < ActiveSupport::TestCase
    test "includes new words when the reviewer reviews new words" do
      reviewer = create(:user, review_attributes: [], review_new_words: true)
      new_word = create(:new_word)

      assert_includes ChangeGroup.reviewable(reviewer).pluck(:id), new_word.change_group_id
    end

    test "excludes new words when the reviewer disabled new words" do
      reviewer = create(:user, review_attributes: [], review_new_words: false)
      new_word = create(:new_word)

      refute_includes ChangeGroup.reviewable(reviewer).pluck(:id), new_word.change_group_id
    end

    test "still includes matching attribute edits when new words are disabled" do
      reviewer = create(:user, review_attributes: ["noun.keywords"], review_new_words: false)
      edit = create(:word_attribute_edit, attribute_name: "keywords")

      assert_includes ChangeGroup.reviewable(reviewer).pluck(:id), edit.change_group_id
    end

    test "returns a change group only once even when several of its edits match" do
      reviewer = create(:user, review_attributes: ["noun.keywords"], review_new_words: false)
      change_group = create(:word_attribute_edit, attribute_name: "keywords").change_group
      create(:word_attribute_edit, attribute_name: "keywords", change_group:)

      ids = ChangeGroup.reviewable(reviewer).pluck(:id)

      assert_equal 1, ids.count(change_group.id)
    end
  end

  class ReviewableTypeCountsTest < ActiveSupport::TestCase
    test "counts pending change groups per type" do
      reviewer = create(:user)
      create(:new_word)
      create(:new_word)
      create(:word_attribute_edit, attribute_name: "keywords")

      counts = ChangeGroup.reviewable_type_counts(reviewer)

      assert_equal 2, counts["new_word"]
      assert_equal 1, counts["keywords"]
    end

    test "ignores change groups the reviewer already reviewed" do
      reviewer = create(:user)
      edit = create(:word_attribute_edit, attribute_name: "keywords")
      edit.change_group.reviews.create!(reviewer: reviewer, state: :skipped)

      counts = ChangeGroup.reviewable_type_counts(reviewer)

      assert_nil counts["keywords"]
    end

    test "counts a type independently of the reviewer's selection" do
      reviewer = create(:user, review_attributes: [], review_new_words: false)
      create(:new_word)

      counts = ChangeGroup.reviewable_type_counts(reviewer)

      assert_equal 1, counts["new_word"]
    end

    test "counts a change group with edits of different types once per type" do
      reviewer = create(:user)
      change_group = create(:word_attribute_edit, attribute_name: "keywords").change_group
      create(:word_attribute_edit, attribute_name: "synonyms", change_group:)

      counts = ChangeGroup.reviewable_type_counts(reviewer)

      assert_equal 1, counts["keywords"]
      assert_equal 1, counts["synonyms"]
    end

    test "counts a change group with several edits of the same type only once" do
      reviewer = create(:user)
      change_group = create(:word_attribute_edit, attribute_name: "keywords").change_group
      create(:word_attribute_edit, attribute_name: "keywords", change_group:)

      counts = ChangeGroup.reviewable_type_counts(reviewer)

      assert_equal 1, counts["keywords"]
    end
  end

  class StoreReviewTest < ActiveSupport::TestCase
    setup do
      @reviewable = create(:word_attribute_edit)
    end

    test "with reviews_required = 1, auto-confirms on first confirmed review" do
      GlobalSetting.reviews_required = 1
      change_group = @reviewable.change_group
      assert_equal "waiting_for_review", change_group.state

      change_group.store_review(reviewer: create(:user), state: :confirmed)

      assert_equal "confirmed", change_group.reload.state
    end

    test "with reviews_required = 1, does not confirm on skip" do
      GlobalSetting.reviews_required = 1
      change_group = @reviewable.change_group
      change_group.store_review(reviewer: create(:user), state: :skipped)

      assert_equal "waiting_for_review", change_group.reload.state
    end

    test "with reviews_required = 1, applies word attribute edits when confirmed" do
      GlobalSetting.reviews_required = 1
      word_attribute_edit = @reviewable
      word = word_attribute_edit.word

      word_attribute_edit.update!(value: "test_value".to_json)
      change_group = word_attribute_edit.change_group

      change_group.store_review(reviewer: create(:user), state: :confirmed)

      assert_equal "test_value", word.reload.case_1_plural
    end

    test "with reviews_required = 2, does not auto-confirm on first confirmed review" do
      GlobalSetting.reviews_required = 2
      user1 = create(:user)
      change_group = @reviewable.change_group
      assert_equal "waiting_for_review", change_group.state

      change_group.store_review(reviewer: user1, state: :confirmed)

      assert_equal "waiting_for_review", change_group.reload.state
      assert_equal 1, change_group.confirmed_review_count
    end

    test "with reviews_required = 2, confirms on second confirmed review" do
      GlobalSetting.reviews_required = 2
      user1 = create(:user)
      user2 = create(:user)
      change_group = @reviewable.change_group

      change_group.store_review(reviewer: user1, state: :confirmed)
      assert_equal "waiting_for_review", change_group.reload.state

      change_group.store_review(reviewer: user2, state: :confirmed)

      assert_equal "confirmed", change_group.reload.state
    end

    test "with reviews_required = 2, does not confirm with one confirmed and one skipped" do
      GlobalSetting.reviews_required = 2
      user1 = create(:user)
      user2 = create(:user)
      change_group = @reviewable.change_group

      change_group.store_review(reviewer: user1, state: :confirmed)
      change_group.store_review(reviewer: user2, state: :skipped)

      assert_equal "waiting_for_review", change_group.reload.state
      assert_equal 1, change_group.confirmed_review_count
    end

    test "with reviews_required = 3, requires 3 confirmed reviews" do
      GlobalSetting.reviews_required = 3
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)
      change_group = @reviewable.change_group

      change_group.store_review(reviewer: user1, state: :confirmed)
      assert_equal "waiting_for_review", change_group.reload.state

      change_group.store_review(reviewer: user2, state: :confirmed)
      assert_equal "waiting_for_review", change_group.reload.state

      change_group.store_review(reviewer: user3, state: :confirmed)
      assert_equal "confirmed", change_group.reload.state
    end
  end

  class DestroyTest < ActiveSupport::TestCase
    setup do
      @original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :good_job
    end

    teardown do
      ActiveJob::Base.queue_adapter = @original_adapter
    end

    test "cancels queued EnrichWordJobs for associated words when destroying change groups" do
      word = create(:noun)
      job = EnrichWordJob.set(wait: 1.hour).perform_later(word.id)

      change_group = create(:word_attribute_edit, word: word).change_group

      queued_job = GoodJob::Job.find_by(active_job_id: job.job_id)
      refute_nil queued_job
      assert_nil queued_job.finished_at

      change_group.destroy

      queued_job.reload
      refute_nil queued_job.finished_at
      assert_includes queued_job.error, "Discarded"
    end

    test "cancels multiple EnrichWordJobs when destroying multiple change groups" do
      word1 = create(:noun)
      word2 = create(:verb)
      job1 = EnrichWordJob.set(wait: 1.hour).perform_later(word1.id)
      job2 = EnrichWordJob.set(wait: 1.hour).perform_later(word2.id)

      change_group1 = create(:word_attribute_edit, word: word1).change_group
      change_group2 = create(:word_attribute_edit, word: word2).change_group

      ChangeGroup.where(id: [change_group1.id, change_group2.id]).destroy_all

      refute_nil GoodJob::Job.find_by(active_job_id: job1.job_id).finished_at
      refute_nil GoodJob::Job.find_by(active_job_id: job2.job_id).finished_at
    end

    test "does not affect jobs for words without associated change groups being deleted" do
      word_with_deletion = create(:noun)
      word_without_deletion = create(:verb)

      job_deleted = EnrichWordJob.set(wait: 1.hour).perform_later(word_with_deletion.id)
      job_kept = EnrichWordJob.set(wait: 1.hour).perform_later(word_without_deletion.id)

      change_group = create(:word_attribute_edit, word: word_with_deletion).change_group

      change_group.destroy

      refute_nil GoodJob::Job.find_by(active_job_id: job_deleted.job_id).finished_at
      assert_nil GoodJob::Job.find_by(active_job_id: job_kept.job_id).finished_at
    end
  end
end
