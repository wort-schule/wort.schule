# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FunctionWord 'ab' page", type: :feature do
  let!(:function_word) { create(:function_word, name: "ab", slug: "ab", function_type: "preposition") }
  let(:user) { create(:user) }

  context "when logged in" do
    before do
      login_as(user, scope: :user)
    end

    it "loads the /ab page successfully" do
      visit "/ab"
      expect(page).to have_http_status(:success)
      expect(page).to have_content("ab")
      expect(page).to have_css("h1", text: /ab/i)
    end

    it "shows the function word details" do
      visit "/ab"
      expect(page).to have_content("Präposition")
    end
  end

  context "when not logged in" do
    it "loads the /ab page successfully" do
      visit "/ab"
      expect(page).to have_http_status(:success)
      expect(page).to have_content("ab")
      expect(page).to have_css("h1", text: /ab/i)
    end

    it "shows the function word details" do
      visit "/ab"
      expect(page).to have_content("Präposition")
    end
  end
end
