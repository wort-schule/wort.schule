# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "change_groups:process_waiting_reviews" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before do
    Rake::Task["change_groups:process_waiting_reviews"].reenable
  end

  it "processes change groups with sufficient confirmed reviews" do
    # Create a change group with 1 confirmed review (meets threshold of REVIEWS_REQUIRED = 1)
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group
    change_group.reviews.create!(reviewer: create(:user), state: :confirmed)

    expect(change_group.reload.state).to eq "waiting_for_review"
    expect(change_group.confirmed_review_count).to eq 1

    # Run the rake task
    Rake::Task["change_groups:process_waiting_reviews"].invoke

    # Verify the change group was processed
    expect(change_group.reload.state).to eq "confirmed"
  end

  it "skips change groups without sufficient confirmed reviews" do
    # Create a change group with 0 confirmed reviews
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group

    expect(change_group.reload.state).to eq "waiting_for_review"
    expect(change_group.confirmed_review_count).to eq 0

    # Run the rake task
    Rake::Task["change_groups:process_waiting_reviews"].invoke

    # Verify the change group was NOT processed
    expect(change_group.reload.state).to eq "waiting_for_review"
  end

  it "skips change groups that are already confirmed" do
    # Create a change group that's already confirmed
    word_attribute_edit = create(:word_attribute_edit)
    change_group = word_attribute_edit.change_group
    change_group.update!(state: :confirmed)

    expect(change_group.reload.state).to eq "confirmed"

    # Run the rake task
    Rake::Task["change_groups:process_waiting_reviews"].invoke

    # Verify the change group remains confirmed (not re-processed)
    expect(change_group.reload.state).to eq "confirmed"
  end

  it "processes multiple qualifying change groups" do
    # Create two change groups with sufficient reviews
    word_attribute_edit1 = create(:word_attribute_edit)
    change_group1 = word_attribute_edit1.change_group
    change_group1.reviews.create!(reviewer: create(:user), state: :confirmed)

    word_attribute_edit2 = create(:word_attribute_edit)
    change_group2 = word_attribute_edit2.change_group
    change_group2.reviews.create!(reviewer: create(:user), state: :confirmed)

    expect(change_group1.reload.state).to eq "waiting_for_review"
    expect(change_group2.reload.state).to eq "waiting_for_review"

    # Run the rake task
    Rake::Task["change_groups:process_waiting_reviews"].invoke

    # Verify both were processed
    expect(change_group1.reload.state).to eq "confirmed"
    expect(change_group2.reload.state).to eq "confirmed"
  end
end
