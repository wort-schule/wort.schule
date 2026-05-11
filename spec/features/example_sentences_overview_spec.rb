# frozen_string_literal: true

RSpec.describe "example sentences overview" do
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  describe "index" do
    let!(:noun) { create :noun, name: "Haus" }

    it "shows words" do
      visit example_sentences_overview_index_path

      expect(page).to have_content("Haus")
      expect(page).to have_content(t("example_sentences_overview.index.title"))
    end

    it "filters words by search" do
      create :noun, name: "Schule"

      visit example_sentences_overview_index_path(q: "Haus*")

      expect(page).to have_content("Haus")
      expect(page).not_to have_content("Schule")
    end
  end

  describe "authorization" do
    let(:guest) { create :guest }

    it "denies access for non-admins" do
      login_as guest

      expect {
        visit example_sentences_overview_index_path
      }.to raise_error(CanCan::AccessDenied)
    end
  end
end
