# frozen_string_literal: true

namespace :debug do
  desc "Debug a specific review/change_group"
  task :review, [:change_group_id] => :environment do |t, args|
    change_group_id = args[:change_group_id] || 5564

    puts "\n=========================================="
    puts "DEBUGGING CHANGE_GROUP #{change_group_id}"
    puts "==========================================\n"

    cg = ChangeGroup.find_by(id: change_group_id)
    unless cg
      puts "❌ ChangeGroup #{change_group_id} not found"
      exit
    end

    puts "ChangeGroup State: #{cg.state}"
    puts "Successor ID: #{cg.successor_id || 'none'}"
    puts "Created at: #{cg.created_at}"
    puts "Updated at: #{cg.updated_at}"
    puts ""

    puts "=== WORD ATTRIBUTE EDITS ==="
    cg.word_attribute_edits.each do |edit|
      puts "  Edit ID: #{edit.id}"
      puts "  Word: #{edit.word.name} (ID: #{edit.word.id})"
      puts "  Attribute: #{edit.attribute_name}"
      puts "  Current value: #{edit.current_value.inspect}"
      puts "  Proposed value: #{edit.proposed_value.inspect}"
      puts "  Stored value (raw): #{edit.value}"
      puts ""
    end

    puts "=== REVIEWS ==="
    cg.reviews.each do |review|
      puts "  Review ID: #{review.id}"
      puts "  State: #{review.state}"
      puts "  Reviewer: #{review.reviewer.email}"
      puts "  Created at: #{review.created_at}"
      puts ""
    end
    puts "Total reviews: #{cg.reviews.count}"
    puts "Confirmed reviews: #{cg.confirmed_review_count}"
    puts "REVIEWS_REQUIRED: #{Reviewable::REVIEWS_REQUIRED}"
    puts ""

    if cg.word_attribute_edits.any?
      first_edit = cg.word_attribute_edits.first
      word = first_edit.word

      puts "=== CURRENT WORD STATE ==="
      puts "Word: #{word.name} (ID: #{word.id})"
      if first_edit.attribute_name == "keywords"
        puts "Current keywords:"
        word.keywords.each do |kw|
          puts "  - #{kw.name} (ID: #{kw.id})"
        end
        puts "  (none)" if word.keywords.empty?

        puts "\nProposed keywords (from edit):"
        first_edit.proposed_value.each do |val|
          if val.to_i.to_s == val.to_s
            kw = Word.find_by(id: val)
            puts "  - #{kw&.name || 'WORD NOT FOUND'} (ID: #{val})"
          else
            puts "  - #{val} (unlisted)"
          end
        end
      end
    end

    puts "\n=== DIAGNOSTIC CHECKS ==="

    # Check if this would be reviewable by an admin
    admin = User.where("review_attributes @> ARRAY['noun.keywords']::varchar[]").first
    if admin
      reviewable = ChangeGroup.reviewable(admin).where(id: change_group_id).exists?
      puts "Would be reviewable by #{admin.email}: #{reviewable ? '✅ YES' : '❌ NO'}"

      # Check why not reviewable
      unless reviewable
        puts "\nReasons why NOT reviewable:"
        puts "  - Has successor: #{cg.successor_id.present? ? '❌ YES' : '✅ NO'}"
        puts "  - State is waiting_for_review: #{cg.state == 'waiting_for_review' ? '✅ YES' : '❌ NO (state: #{cg.state})'}"

        reviewer_exists = Reviewer.where(change_group_id: cg.id, reviewer_id: admin.id).exists?
        puts "  - Already reviewed by this admin: #{reviewer_exists ? '❌ YES' : '✅ NO'}"

        if reviewer_exists
          puts "\n    Reviews by #{admin.email} on this change_group:"
          Review.where(reviewable: cg, reviewer: admin).each do |r|
            puts "      - #{r.state} at #{r.created_at}"
          end
        end
      end
    else
      puts "No admin found with keyword review permissions"
    end

    # Check if keywords should have been applied
    if cg.state == "confirmed"
      puts "\n✅ ChangeGroup is CONFIRMED - keywords SHOULD be applied"
      puts "Checking if they were actually applied..."

      cg.word_attribute_edits.where(attribute_name: "keywords").each do |edit|
        word = edit.word
        proposed = edit.proposed_value
        current_ids = word.keywords.pluck(:id).map(&:to_s)
        proposed_ids = proposed.select { |v| v.to_i.to_s == v.to_s }

        missing = proposed_ids - current_ids
        if missing.any?
          puts "  ❌ Missing keywords on #{word.name}:"
          missing.each do |id|
            kw = Word.find_by(id: id)
            puts "    - #{kw&.name || 'NOT FOUND'} (ID: #{id})"
          end
        else
          puts "  ✅ All proposed listed keywords are applied to #{word.name}"
        end
      end
    end

    puts "\n=========================================="
    puts "END OF DEBUG REPORT"
    puts "==========================================\n"
  end
end
