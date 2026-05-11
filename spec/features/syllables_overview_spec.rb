# frozen_string_literal: true

RSpec.describe "syllables overview" do
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  describe "index" do
    let!(:noun) { create :noun, name: "Zelle", syllables: "Zel-le", written_syllables: "Zel|le" }

    it "shows words with syllables" do
      visit syllables_overview_index_path

      expect(page).to have_content("Zelle")
      expect(page).to have_content(t("syllables_overview.index.title"))
    end

    it "filters words by search" do
      create :noun, name: "Haus", syllables: "Haus"

      visit syllables_overview_index_path(q: "Zel*")

      expect(page).to have_content("Zelle")
      expect(page).not_to have_content("Haus")
    end

    it "filters words missing syllables" do
      create :noun, name: "Baum", syllables: nil

      visit syllables_overview_index_path(syllable_filter: "missing_syllables")

      expect(page).to have_content("Baum")
      expect(page).not_to have_content("Zelle")
    end
  end

  describe "authorization" do
    let(:guest) { create :guest }

    it "denies access for non-admins" do
      login_as guest

      expect {
        visit syllables_overview_index_path
      }.to raise_error(CanCan::AccessDenied)
    end
  end
end
