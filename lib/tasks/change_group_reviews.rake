# frozen_string_literal: true

namespace :change_groups do
  desc "Process waiting change groups and finish reviews if criteria met"
  task process_waiting_reviews: :environment do
    processed_count = 0
    skipped_count = 0

    ChangeGroup.where(state: :waiting_for_review).find_each do |change_group|
      required_reviews = GlobalSetting.reviews_required
      if change_group.confirmed_review_count >= required_reviews
        puts "[PROCESS] ChangeGroup ##{change_group.id} (#{change_group.confirmed_review_count} confirmed reviews)"
        change_group.try_to_finish_review
        processed_count += 1
      else
        skipped_count += 1
      end
    end

    puts
    puts "Summary:"
    puts "  Processed: #{processed_count} change groups"
    puts "  Skipped:   #{skipped_count} change groups (insufficient reviews)"
  end
end
