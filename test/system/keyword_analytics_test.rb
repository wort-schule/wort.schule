# frozen_string_literal: true

require "application_system_test_case"

class KeywordAnalyticsTest < ApplicationSystemTestCase
  test "allows admins to access the page" do
    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.title")
  end

  test "denies access to regular users" do
    user = create(:user)
    login_as user

    assert_raises(CanCan::AccessDenied) { visit keyword_analytics_path }
  end

  test "displays overview statistics" do
    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.overview")
    assert_text I18n.t("keyword_analytics.index.total_records")
    assert_text I18n.t("keyword_analytics.index.overall_success_rate")
  end

  test "shows no data message when empty" do
    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.no_data")
  end

  test "displays problematic words with analytics data" do
    word = create(:noun, name: "TestWort")
    keyword = create(:noun, name: "TestKeyword")

    pick_id = SecureRandom.uuid
    5.times do |i|
      create(:keyword_effectiveness,
        word: word,
        keyword: keyword,
        pick_id: pick_id,
        led_to_correct: false,
        keyword_position: i + 1)
      pick_id = SecureRandom.uuid
    end

    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text "TestWort"
    assert_text "100"
  end

  test "displays top and worst performing keywords" do
    good_keyword = create(:noun, name: "GutesKeyword")
    bad_keyword = create(:noun, name: "SchlechtesKeyword")
    word = create(:noun, name: "TestWort")

    5.times do
      create(:keyword_effectiveness,
        word: word,
        keyword: good_keyword,
        pick_id: SecureRandom.uuid,
        led_to_correct: true,
        keyword_position: 1)
    end

    5.times do
      create(:keyword_effectiveness,
        word: word,
        keyword: bad_keyword,
        pick_id: SecureRandom.uuid,
        led_to_correct: false,
        keyword_position: 1)
    end

    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.top_keywords_title")
    assert_text I18n.t("keyword_analytics.index.worst_keywords_title")
    assert_text "GutesKeyword"
    assert_text "SchlechtesKeyword"
  end

  test "displays recent activity statistics" do
    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.recent_activity")
    assert_text I18n.t("keyword_analytics.index.last_24h")
    assert_text I18n.t("keyword_analytics.index.last_7d")
    assert_text I18n.t("keyword_analytics.index.last_30d")
  end

  test "displays data interpretation help" do
    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.understanding_data")
    assert_text I18n.t("keyword_analytics.index.good_keyword")
    assert_text I18n.t("keyword_analytics.index.poor_keyword")
  end

  test "displays all keyword-word pairs table" do
    word = create(:noun, name: "ZielWort")
    keyword = create(:noun, name: "HilfeKeyword")

    3.times do
      create(:keyword_effectiveness,
        word: word,
        keyword: keyword,
        pick_id: SecureRandom.uuid,
        led_to_correct: true,
        keyword_position: 1)
    end

    admin = create(:admin)
    login_as admin
    visit keyword_analytics_path

    assert_text I18n.t("keyword_analytics.index.all_pairs_title")
    assert_text "ZielWort"
    assert_text "HilfeKeyword"
  end

  test "displays word analytics details on show page" do
    word = create(:noun, name: "AnalyticsWort")
    keyword1 = create(:noun, name: "Keyword1")
    keyword2 = create(:noun, name: "Keyword2")
    pick_id = SecureRandom.uuid
    round_id = SecureRandom.uuid

    create(:keyword_effectiveness,
      word: word,
      keyword: keyword1,
      pick_id: pick_id,
      round_id: round_id,
      keyword_position: 1,
      led_to_correct: true)

    create(:keyword_effectiveness,
      word: word,
      keyword: keyword2,
      pick_id: pick_id,
      round_id: round_id,
      keyword_position: 2,
      led_to_correct: true)

    admin = create(:admin)
    login_as admin
    visit keyword_analytic_path(word)

    assert_text "AnalyticsWort"
    assert_text I18n.t("keyword_analytics.show.keyword_performance")
    assert_text "Keyword1"
    assert_text "Keyword2"
  end

  test "displays position analysis on show page" do
    word = create(:noun, name: "AnalyticsWort")
    keyword1 = create(:noun, name: "Keyword1")
    pick_id = SecureRandom.uuid
    round_id = SecureRandom.uuid

    create(:keyword_effectiveness,
      word: word,
      keyword: keyword1,
      pick_id: pick_id,
      round_id: round_id,
      keyword_position: 1,
      led_to_correct: true)

    admin = create(:admin)
    login_as admin
    visit keyword_analytic_path(word)

    assert_text I18n.t("keyword_analytics.show.position_analysis")
  end

  test "has a back link to the index on show page" do
    word = create(:noun, name: "AnalyticsWort")
    keyword1 = create(:noun, name: "Keyword1")
    pick_id = SecureRandom.uuid
    round_id = SecureRandom.uuid

    create(:keyword_effectiveness,
      word: word,
      keyword: keyword1,
      pick_id: pick_id,
      round_id: round_id,
      keyword_position: 1,
      led_to_correct: true)

    admin = create(:admin)
    login_as admin
    visit keyword_analytic_path(word)

    assert_link I18n.t("keyword_analytics.show.back_to_list")
  end
end
