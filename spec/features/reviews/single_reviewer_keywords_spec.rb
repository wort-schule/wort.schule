# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Single reviewer confirming keywords", :js do
  let(:admin) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let(:word) { create(:noun, name: "Adler") }
  let(:keyword) { create(:noun, name: "Vogel") }

  it "applies keywords immediately when a single reviewer confirms" do
    # Create a word_attribute_edit for keywords
    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [keyword.id.to_s].to_json,
      word: word
    )

    # Verify word has no keywords initially
    expect(word.keywords).to be_empty
    expect(edit.change_group.state).to eq "waiting_for_review"

    # Login and visit reviews page
    login_as admin
    visit reviews_path

    # Should see the word
    expect(page).to have_content word.name

    # Manually select the keyword (keywords are not preselected)
    within '[data-toggle-buttons-target="list"]' do
      click_on keyword.name
    end

    # Confirm the review
    click_on I18n.t("reviews.show.actions.confirm")

    # After confirmation, check database state
    edit.reload
    expect(edit.change_group.state).to eq "confirmed"
    expect(edit.change_group.reviews.count).to eq 1
    expect(edit.change_group.reviews.first.state).to eq "confirmed"

    # Check that keyword was applied
    word.reload
    expect(word.keywords.map(&:id)).to include(keyword.id)
    expect(word.keywords.map(&:name)).to include("Vogel")

    # Now check if it appears on the word page
    visit "/adler"
    expect(page).to have_content "Vogel"
  end

  it "logs the review process for debugging" do
    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [keyword.id.to_s].to_json,
      word: word
    )

    puts "\n=== INITIAL STATE ==="
    puts "Word: #{word.name} (ID: #{word.id})"
    puts "Keyword: #{keyword.name} (ID: #{keyword.id})"
    puts "Word keywords: #{word.keywords.map(&:name)}"
    puts "ChangeGroup state: #{edit.change_group.state}"
    puts "WordAttributeEdit value: #{edit.value}"
    puts "WordAttributeEdit proposed_value: #{edit.proposed_value.inspect}"

    login_as admin
    visit reviews_path

    puts "\n=== ON REVIEW PAGE ==="
    puts "Current path: #{current_path}"
    puts "ChangeGroup ID: #{edit.change_group.id}"

    # Check the select element
    select_element = page.find('select[data-toggle-buttons-target="input"]', visible: false)
    puts "Select options: #{select_element.all("option", visible: false).map { |o| [o.value, o["selected"]] }.inspect}"

    # Manually select the keyword (keywords are not preselected)
    within '[data-toggle-buttons-target="list"]' do
      click_on keyword.name
    end

    click_on I18n.t("reviews.show.actions.confirm")

    puts "\n=== AFTER CONFIRMATION ==="
    edit.reload
    word.reload
    puts "ChangeGroup state: #{edit.change_group.state}"
    puts "Reviews count: #{edit.change_group.reviews.count}"
    edit.change_group.reviews.each do |review|
      puts "  Review state: #{review.state}, reviewer: #{review.reviewer.email}"
    end
    puts "Word keywords: #{word.keywords.map(&:name)}"

    # Visit word page
    visit "/adler"
    puts "\n=== ON WORD PAGE ==="
    puts "Current path: #{current_path}"
    puts "Page text includes 'Vogel': #{page.has_content?("Vogel")}"
  end
end
