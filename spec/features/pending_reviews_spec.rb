# frozen_string_literal: true

require "rails_helper"

RSpec.describe "pending reviews page" do
  let(:me) { create :admin }

  it "displays pending reviews with new word proposals without errors" do
    new_word = create(:new_word)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content new_word.name
    expect(page).to have_content new_word.topic
    expect(page).to have_content I18n.t("pending_reviews.index.new")
  end

  it "displays pending reviews with word attribute edits" do
    word = create(:noun, meaning: "a male cat")
    create(:word_attribute_edit, word:)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content word.name
    expect(page).to have_content I18n.t("pending_reviews.index.attribute_edits", count: 1)
  end

  it "displays human-readable keyword names instead of IDs" do
    word = create(:noun, name: "Test Word")
    keyword1 = create(:noun, name: "Keyword 1")
    keyword2 = create(:noun, name: "Keyword 2")

    # Create an edit with keyword IDs using the correct attribute name "keywords"
    create(:word_attribute_edit, word:, attribute_name: "keywords", value: [keyword1.id, keyword2.id].to_json)

    login_as me
    visit pending_reviews_path

    expect(page).to have_content word.name
    # Verify we see the keyword names, not the IDs
    expect(page).to have_content "Keyword 1"
    expect(page).to have_content "Keyword 2"
  end

  it "displays human-readable keyword names for comma-separated string format" do
    word = create(:noun, name: "Test Word 2")
    keyword1 = create(:noun, name: "Keyword A")
    keyword2 = create(:noun, name: "Keyword B")

    # Create an edit with keyword IDs in string format (comma-separated)
    create(:word_attribute_edit, word:, attribute_name: "keywords", value: "\"#{keyword1.id}, #{keyword2.id}\"")

    login_as me
    visit pending_reviews_path

    expect(page).to have_content word.name
    # Verify we see the keyword names, not the IDs
    expect(page).to have_content "Keyword A"
    expect(page).to have_content "Keyword B"
  end

  describe "pagination" do
    it "displays 250 items per page by default" do
      # Create 260 pending reviews with distinct timestamps
      260.times do |i|
        word = create(:noun, name: "Word #{i.to_s.rjust(3, "0")}")
        # Add a small delay to ensure distinct timestamps
        create(:word_attribute_edit, word:, created_at: i.seconds.ago)
      end

      login_as me
      visit pending_reviews_path

      # Should display showing "1-250 of 260"
      expect(page).to have_content "Zeige 1-250 von 260"

      # Should have pagination controls
      expect(page).to have_link("2")

      # Count the number of "Review starten" links (one per row)
      expect(page).to have_link("Review starten", count: 250)
    end

    it "allows changing the page size" do
      # Create 60 pending reviews
      60.times do |i|
        word = create(:noun, name: "PaginationTest #{i}")
        create(:word_attribute_edit, word:)
      end

      login_as me
      visit pending_reviews_path(per_page: 25)

      # Should see first 25 items (newest first: PaginationTest 59 down to PaginationTest 35)
      expect(page).to have_content "PaginationTest 59"
      expect(page).to have_content "PaginationTest 35"
      # Should not see PaginationTest 34
      expect(page).not_to have_content "PaginationTest 34"

      # Should have pagination controls showing page 3
      expect(page).to have_link("3")
    end

    it "preserves per_page parameter when navigating pages" do
      # Create 60 pending reviews
      60.times do |i|
        word = create(:noun, name: "NavTest #{i}")
        create(:word_attribute_edit, word:)
      end

      login_as me
      visit pending_reviews_path(per_page: 20)

      # Click to page 2 (first occurrence in top pagination)
      first(:link, "2").click

      # Should still use per_page=20
      # Page 2 should show NavTest 39 down to NavTest 20 (sorted DESC by created_at)
      expect(page).to have_content "NavTest 39"
      expect(page).to have_content "NavTest 20"
      expect(page).not_to have_content "NavTest 19"
      expect(page).not_to have_content "NavTest 59"
    end

    it "preserves sorting when paginating" do
      # Create some reviews with different creation times
      word1 = create(:noun, name: "Oldest Word")
      create(:word_attribute_edit, word: word1, created_at: 3.days.ago)

      word2 = create(:noun, name: "Newest Word")
      create(:word_attribute_edit, word: word2, created_at: 1.day.ago)

      login_as me
      visit pending_reviews_path(sort_by: "created_at", sort_direction: "asc")

      # Should see oldest first
      within("tbody tr:first-child") do
        expect(page).to have_content "Oldest Word"
      end
    end
  end

  describe "table filtering" do
    it "filters the table by exact word name" do
      word1 = create(:noun, name: "Apple")
      create(:word_attribute_edit, word: word1)

      word2 = create(:noun, name: "Banana")
      create(:word_attribute_edit, word: word2)

      login_as me
      visit pending_reviews_path

      # Initially both should be visible
      expect(page).to have_content "Apple"
      expect(page).to have_content "Banana"

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter for Apple
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Apple"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should only see Apple
      expect(page).to have_content "Apple"
      expect(page).not_to have_content "Banana"
      expect(page).to have_content I18n.t("pending_reviews.index.filtered_by", filter: "Apple")
    end

    it "filters the table with wildcard patterns" do
      word1 = create(:noun, name: "TestWord1")
      create(:word_attribute_edit, word: word1)

      word2 = create(:noun, name: "TestWord2")
      create(:word_attribute_edit, word: word2)

      word3 = create(:noun, name: "OtherWord")
      create(:word_attribute_edit, word: word3)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter with wildcard
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Test*"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should only see TestWord entries
      expect(page).to have_content "TestWord1"
      expect(page).to have_content "TestWord2"
      expect(page).not_to have_content "OtherWord"
      expect(page).to have_content "Zeige 1-2 von 2"
    end

    it "can clear the filter" do
      word1 = create(:noun, name: "Apple")
      create(:word_attribute_edit, word: word1)

      word2 = create(:noun, name: "Banana")
      create(:word_attribute_edit, word: word2)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Apply filter
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Apple"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      expect(page).to have_content "Apple"
      expect(page).not_to have_content "Banana"

      # Clear filter
      click_link I18n.t("pending_reviews.index.clear_filter")

      # Should see both again
      expect(page).to have_content "Apple"
      expect(page).to have_content "Banana"
      expect(page).not_to have_content I18n.t("pending_reviews.index.filtered_by", filter: "Apple")
    end

    it "preserves filter when changing pagination" do
      30.times do |i|
        word = create(:noun, name: "FilterTest #{i}")
        create(:word_attribute_edit, word:)
      end

      word = create(:noun, name: "OtherWord")
      create(:word_attribute_edit, word:)

      login_as me
      visit pending_reviews_path(per_page: 10)

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Apply filter
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "FilterTest*"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should show 10 items on page 1
      expect(page).to have_content "Zeige 1-10 von 30"
      expect(page).not_to have_content "OtherWord"

      # Go to page 2 (click within pagination wrapper)
      within(first(".pagination-wrapper")) do
        click_link "2"
      end

      # Filter should still be applied
      expect(page).to have_content "Zeige 11-20 von 30"
      expect(page).not_to have_content "OtherWord"
      expect(page).to have_content I18n.t("pending_reviews.index.filtered_by", filter: "FilterTest*")
    end

    it "preserves filter when sorting" do
      word1 = create(:noun, name: "Apple")
      create(:word_attribute_edit, word: word1, created_at: 2.days.ago)

      word2 = create(:noun, name: "Apricot")
      create(:word_attribute_edit, word: word2, created_at: 1.day.ago)

      word3 = create(:noun, name: "Banana")
      create(:word_attribute_edit, word: word3, created_at: 3.days.ago)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Apply filter
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "Ap*"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      expect(page).to have_content "Apple"
      expect(page).to have_content "Apricot"
      expect(page).not_to have_content "Banana"

      # Sort by word name
      within("thead") do
        click_link I18n.t("pending_reviews.index.word")
      end

      # Filter should still be applied
      expect(page).to have_content "Apple"
      expect(page).to have_content "Apricot"
      expect(page).not_to have_content "Banana"
      expect(page).to have_content I18n.t("pending_reviews.index.filtered_by", filter: "Ap*")
    end

    it "filters new word proposals as well" do
      create(:new_word, name: "NewApple")
      create(:new_word, name: "NewBanana")

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter for Apple
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NewApple"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should only see NewApple
      expect(page).to have_content "NewApple"
      expect(page).not_to have_content "NewBanana"
    end
  end

  describe "filter functionality" do
    it "has filter collapsed by default" do
      word = create(:noun, name: "TestWord")
      create(:word_attribute_edit, word:)

      login_as me
      visit pending_reviews_path

      # The filter section should be collapsed (hidden)
      expect(page).to have_css("details.filter-section:not([open])")
    end

    it "can expand the filter section" do
      word = create(:noun, name: "TestWord")
      create(:word_attribute_edit, word:)

      login_as me
      visit pending_reviews_path

      # Click to expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Now filter inputs should be visible
      expect(page).to have_field(I18n.t("pending_reviews.index.filter_table_placeholder"))
    end

    it "filters by word type (Wortart)" do
      noun = create(:noun, name: "TestNoun")
      create(:word_attribute_edit, word: noun)

      verb = create(:verb, name: "TestVerb")
      create(:word_attribute_edit, word: verb)

      adjective = create(:adjective, name: "TestAdjective")
      create(:word_attribute_edit, word: adjective)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter for Nouns only (using the raw class name since that's what the select uses)
      select "Noun", from: I18n.t("pending_reviews.index.word_type_filter")
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should only see the noun
      expect(page).to have_content "TestNoun"
      expect(page).not_to have_content "TestVerb"
      expect(page).not_to have_content "TestAdjective"
    end

    it "filters by keywords (Stichwörter)" do
      keyword1 = create(:noun, name: "Keyword1")
      keyword2 = create(:noun, name: "Keyword2")

      word1 = create(:noun, name: "Word1")
      create(:word_attribute_edit, word: word1, attribute_name: "keywords", value: [keyword1.id].to_json)

      word2 = create(:noun, name: "Word2")
      create(:word_attribute_edit, word: word2, attribute_name: "keywords", value: [keyword2.id].to_json)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter by keyword name (not ID)
      fill_in I18n.t("pending_reviews.index.keyword_filter"), with: "Keyword1"
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should only see Word1
      expect(page).to have_content "Word1"
      expect(page).not_to have_content "Word2"
    end

    it "shows filter examples to help users" do
      # Need at least one review to see the filters
      word = create(:noun, name: "TestWord")
      create(:word_attribute_edit, word:)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Should show examples
      expect(page).to have_content I18n.t("pending_reviews.index.filter_examples")
    end
  end

  describe "deletion functionality" do
    it "can delete filtered results from the main filter" do
      word1 = create(:noun, name: "DeleteMe")
      change_group1 = create(:word_attribute_edit, word: word1).change_group

      word2 = create(:noun, name: "KeepMe")
      change_group2 = create(:word_attribute_edit, word: word2).change_group

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter for DeleteMe
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "DeleteMe"

      # Check the delete checkbox
      check I18n.t("pending_reviews.index.delete_filtered_checkbox")

      # Submit the form
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should show confirmation
      expect(page).to have_content(I18n.t("pending_reviews.index.confirm_deletion", count: 1))

      # Confirm deletion
      click_button I18n.t("pending_reviews.index.confirm_delete")

      # Should show success message
      expect(page).to have_content(I18n.t("pending_reviews.index.deletion_success", count: 1))

      # Verify deletion
      expect(ChangeGroup.exists?(change_group1.id)).to be false
      expect(ChangeGroup.exists?(change_group2.id)).to be true
    end

    it "deletes change groups matching wildcard pattern" do
      word1 = create(:noun, name: "TestWord1")
      change_group1 = create(:word_attribute_edit, word: word1).change_group

      word2 = create(:noun, name: "TestWord2")
      change_group2 = create(:word_attribute_edit, word: word2).change_group

      word3 = create(:noun, name: "KeepThis")
      change_group3 = create(:word_attribute_edit, word: word3).change_group

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Filter and delete
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "TestWord*"
      check I18n.t("pending_reviews.index.delete_filtered_checkbox")
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should show confirmation with count
      expect(page).to have_content(I18n.t("pending_reviews.index.confirm_deletion", count: 2))

      # Confirm deletion
      click_button I18n.t("pending_reviews.index.confirm_delete")

      # Should show success message
      expect(page).to have_content(I18n.t("pending_reviews.index.deletion_success", count: 2))

      # Verify deletions
      expect(ChangeGroup.exists?(change_group1.id)).to be false
      expect(ChangeGroup.exists?(change_group2.id)).to be false
      expect(ChangeGroup.exists?(change_group3.id)).to be true

      expect(page).to have_content "KeepThis"
    end

    it "shows message when no matches found for filter" do
      word = create(:noun, name: "ExistingWord")
      create(:word_attribute_edit, word:)

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Try to delete non-existent
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NonExistent*"
      check I18n.t("pending_reviews.index.delete_filtered_checkbox")
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Should show no matches message
      expect(page).to have_content(I18n.t("pending_reviews.index.no_matches"))
    end

    it "allows canceling deletion confirmation" do
      word = create(:noun, name: "CancelTest")
      change_group = create(:word_attribute_edit, word:).change_group

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Request deletion
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "CancelTest"
      check I18n.t("pending_reviews.index.delete_filtered_checkbox")
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Cancel the deletion (it's a link, not a button)
      click_link I18n.t("pending_reviews.index.cancel")

      # Should still exist
      expect(ChangeGroup.exists?(change_group.id)).to be true
      expect(page).to have_content "CancelTest"
    end

    it "handles deletion of new word proposals" do
      new_word1 = create(:new_word, name: "NewWord1")
      change_group1 = new_word1.change_group

      new_word2 = create(:new_word, name: "NewWord2")
      change_group2 = new_word2.change_group

      login_as me
      visit pending_reviews_path

      # Expand filter
      find("summary", text: I18n.t("pending_reviews.index.show_filters")).click

      # Delete NewWord1
      fill_in I18n.t("pending_reviews.index.filter_table_placeholder"), with: "NewWord1"
      check I18n.t("pending_reviews.index.delete_filtered_checkbox")
      click_button I18n.t("pending_reviews.index.filter_table_button")

      # Confirm deletion
      click_button I18n.t("pending_reviews.index.confirm_delete")

      # Verify deletion
      expect(ChangeGroup.exists?(change_group1.id)).to be false
      expect(ChangeGroup.exists?(change_group2.id)).to be true
    end
  end

  describe "page layout improvements" do
    it "displays a proper h1 heading" do
      login_as me
      visit pending_reviews_path

      expect(page).to have_css("h1", text: I18n.t("pending_reviews.index.title"))
    end

    it "has pagination controls at top and bottom of table" do
      # Create enough items to trigger pagination
      260.times do |i|
        word = create(:noun, name: "Word #{i.to_s.rjust(3, "0")}")
        create(:word_attribute_edit, word:)
      end

      login_as me
      visit pending_reviews_path(per_page: 50)

      # Find all pagination sections
      pagination_sections = all(".pagination-wrapper")
      expect(pagination_sections.count).to eq(2)

      # Both should have the same page links
      pagination_sections.each do |section|
        within(section) do
          expect(page).to have_link("2")
        end
      end
    end
  end
end
