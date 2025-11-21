# frozen_string_literal: true

require "rails_helper"

RSpec.describe "keyword analytics page" do
  let(:admin) { create :admin }
  let(:user) { create :user }

  describe "access control" do
    it "allows admins to access the page" do
      login_as admin
      visit keyword_analytics_path

      expect(page).to have_content I18n.t("keyword_analytics.index.title")
    end

    it "denies access to regular users" do
      login_as user

      expect { visit keyword_analytics_path }.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "index page" do
    it "displays overview statistics" do
      login_as admin
      visit keyword_analytics_path

      expect(page).to have_content I18n.t("keyword_analytics.index.overview")
      expect(page).to have_content I18n.t("keyword_analytics.index.total_records")
      expect(page).to have_content I18n.t("keyword_analytics.index.overall_success_rate")
    end

    it "shows no data message when empty" do
      login_as admin
      visit keyword_analytics_path

      expect(page).to have_content I18n.t("keyword_analytics.index.no_data")
    end

    it "displays problematic words with analytics data" do
      word = create(:noun, name: "TestWort")
      keyword = create(:noun, name: "TestKeyword")

      # Create multiple failed attempts for this word
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

      login_as admin
      visit keyword_analytics_path

      expect(page).to have_content "TestWort"
      expect(page).to have_content "100" # 100% failure rate
    end
  end

  describe "show page" do
    let(:word) { create(:noun, name: "AnalyticsWort") }
    let(:keyword1) { create(:noun, name: "Keyword1") }
    let(:keyword2) { create(:noun, name: "Keyword2") }

    before do
      # Create some analytics data
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
    end

    it "displays word analytics details" do
      login_as admin
      visit keyword_analytic_path(word)

      expect(page).to have_content "AnalyticsWort"
      expect(page).to have_content I18n.t("keyword_analytics.show.keyword_performance")
      expect(page).to have_content "Keyword1"
      expect(page).to have_content "Keyword2"
    end

    it "displays position analysis" do
      login_as admin
      visit keyword_analytic_path(word)

      expect(page).to have_content I18n.t("keyword_analytics.show.position_analysis")
    end

    it "has a back link to the index" do
      login_as admin
      visit keyword_analytic_path(word)

      expect(page).to have_link I18n.t("keyword_analytics.show.back_to_list")
    end
  end
end
