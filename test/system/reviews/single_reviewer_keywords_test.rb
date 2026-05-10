# frozen_string_literal: true

require "application_system_test_case"

class ReviewsSingleReviewerKeywordsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @word = create(:noun, name: "Adler")
    @keyword = create(:noun, name: "Vogel")
  end

  test "applies keywords immediately when a single reviewer confirms" do
    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [@keyword.id.to_s].to_json,
      word: @word
    )

    assert_empty @word.keywords
    assert_equal "waiting_for_review", edit.change_group.state

    login_as @admin
    visit reviews_path

    assert_text @word.name

    within '[data-toggle-buttons-target="list"]' do
      click_on @keyword.name
    end

    click_on I18n.t("reviews.show.actions.confirm")

    edit.reload
    assert_equal "confirmed", edit.change_group.state
    assert_equal 1, edit.change_group.reviews.count
    assert_equal "confirmed", edit.change_group.reviews.first.state

    @word.reload
    assert_includes @word.keywords.map(&:id), @keyword.id
    assert_includes @word.keywords.map(&:name), "Vogel"

    visit "/adler"
    assert_text "Vogel"
  end

  test "logs the review process for debugging" do
    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [@keyword.id.to_s].to_json,
      word: @word
    )

    puts "\n=== INITIAL STATE ==="
    puts "Word: #{@word.name} (ID: #{@word.id})"
    puts "Keyword: #{@keyword.name} (ID: #{@keyword.id})"
    puts "Word keywords: #{@word.keywords.map(&:name)}"
    puts "ChangeGroup state: #{edit.change_group.state}"
    puts "WordAttributeEdit value: #{edit.value}"
    puts "WordAttributeEdit proposed_value: #{edit.proposed_value.inspect}"

    login_as @admin
    visit reviews_path

    puts "\n=== ON REVIEW PAGE ==="
    puts "Current path: #{current_path}"
    puts "ChangeGroup ID: #{edit.change_group.id}"

    select_element = page.find('select[data-toggle-buttons-target="input"]', visible: false)
    puts "Select options: #{select_element.all("option", visible: false).map { |o| [o.value, o["selected"]] }.inspect}"

    within '[data-toggle-buttons-target="list"]' do
      click_on @keyword.name
    end

    click_on I18n.t("reviews.show.actions.confirm")

    puts "\n=== AFTER CONFIRMATION ==="
    edit.reload
    @word.reload
    puts "ChangeGroup state: #{edit.change_group.state}"
    puts "Reviews count: #{edit.change_group.reviews.count}"
    edit.change_group.reviews.each do |review|
      puts "  Review state: #{review.state}, reviewer: #{review.reviewer.email}"
    end
    puts "Word keywords: #{@word.keywords.map(&:name)}"

    visit "/adler"
    puts "\n=== ON WORD PAGE ==="
    puts "Current path: #{current_path}"
    puts "Page text includes 'Vogel': #{page.has_content?("Vogel")}"
  end

  test "allows selecting a subset of proposed keywords when reviews_required is 1" do
    GlobalSetting.reviews_required = 1

    keyword2 = create(:noun, name: "Tier")
    keyword3 = create(:noun, name: "Fliegen")

    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [@keyword.id.to_s, keyword2.id.to_s, keyword3.id.to_s].to_json,
      word: @word
    )

    assert_empty @word.keywords
    assert_equal "waiting_for_review", edit.change_group.state

    login_as @admin
    visit reviews_path

    assert_text @word.name

    within '[data-toggle-buttons-target="list"]' do
      click_on @keyword.name
      click_on keyword2.name
    end

    click_on I18n.t("reviews.show.actions.confirm")

    edit.reload
    assert_equal "confirmed", edit.change_group.state
    assert_equal 1, edit.change_group.reviews.count

    @word.reload
    assert_equal [@keyword.name, keyword2.name].sort, @word.keywords.map(&:name).sort
    refute_includes @word.keywords.map(&:name), keyword3.name
  end

  test "allows adding new keywords when reviews_required is 1" do
    GlobalSetting.reviews_required = 1

    new_keyword = create(:noun, name: "Schnabel")

    edit = create(
      :word_attribute_edit,
      attribute_name: "keywords",
      value: [@keyword.id.to_s].to_json,
      word: @word
    )

    assert_empty @word.keywords
    assert_equal "waiting_for_review", edit.change_group.state

    login_as @admin
    visit reviews_path

    assert_text @word.name

    within '[data-toggle-buttons-target="list"]' do
      click_on @keyword.name
    end

    tom_select_input = find('[data-toggle-buttons-target="add"] + .ts-wrapper .ts-control input')
    tom_select_input.fill_in with: new_keyword.name
    find(".ts-dropdown .option", text: new_keyword.name).click

    tom_select_input.send_keys(:escape)

    click_on I18n.t("reviews.show.actions.confirm")

    edit.reload
    assert_equal "confirmed", edit.change_group.state
    assert_equal 1, edit.change_group.reviews.count

    @word.reload
    assert_equal [@keyword.name, new_keyword.name].sort, @word.keywords.map(&:name).sort
  end
end
