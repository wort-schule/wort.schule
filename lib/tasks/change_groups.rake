# frozen_string_literal: true

namespace :change_groups do
  desc "Fix limbo change groups that can't be reviewed due to attribute name prefix issues"
  task fix_limbo: :environment do
    puts "Checking for limbo change groups..."

    # Find WordAttributeEdits with prefixed attribute_names (e.g., "noun.case_1_plural")
    prefixed_edits = WordAttributeEdit.where("attribute_name LIKE '%.%'")

    if prefixed_edits.empty?
      puts "No prefixed attribute names found. Nothing to fix."
      next
    end

    puts "Found #{prefixed_edits.count} word_attribute_edits with prefixed attribute names."

    fixed_count = 0
    prefixed_edits.find_each do |edit|
      # Extract the attribute name without the type prefix
      # e.g., "noun.case_1_plural" => "case_1_plural"
      _type, attribute = edit.attribute_name.split(".", 2)

      if attribute
        puts "  Fixing: #{edit.attribute_name} => #{attribute}"
        edit.update!(attribute_name: attribute)
        fixed_count += 1
      else
        puts "  Skipping: #{edit.attribute_name} (no prefix found)"
      end
    end

    puts "\nFixed #{fixed_count} word_attribute_edits."
    puts "These change groups should now be reviewable."
  end

  desc "List change groups that are stuck in limbo (no eligible reviewers)"
  task list_limbo: :environment do
    waiting_groups = ChangeGroup.where(state: :waiting_for_review, successor_id: nil)
    users_with_review_attrs = User.where.not(review_attributes: [])

    puts "Total change groups waiting for review: #{waiting_groups.count}"
    puts "Users with review attributes: #{users_with_review_attrs.count}"
    puts

    limbo_groups = []

    waiting_groups.includes(:word_attribute_edits, :new_word).find_each do |cg|
      can_be_reviewed = users_with_review_attrs.any? do |user|
        ChangeGroup.reviewable(user).where(id: cg.id).exists?
      end

      unless can_be_reviewed
        limbo_groups << cg
      end
    end

    if limbo_groups.empty?
      puts "✓ No limbo change groups found!"
    else
      puts "⚠ Found #{limbo_groups.count} change groups in limbo:"
      limbo_groups.each do |cg|
        puts "\n  ChangeGroup ##{cg.id}:"
        if cg.new_word
          puts "    Type: new_word"
          puts "    Word: #{cg.new_word.name} (#{cg.new_word.word_type})"
        end
        if cg.word_attribute_edits.any?
          puts "    Type: word_attribute_edits"
          puts "    Attributes: #{cg.word_attribute_edits.pluck(:attribute_name).join(", ")}"
        end
        puts "    Created: #{cg.created_at}"
        puts "    Reviews: #{cg.reviews.count}"
      end
    end
  end
end
