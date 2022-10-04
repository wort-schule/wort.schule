# frozen_string_literal: true

RSpec.describe "nouns" do
  describe "managing nouns" do
    it_behaves_like "CRUD", Noun
  end

  describe "change history" do
    let!(:word) { create :noun, name: "Buche" }

    context "when logged in as a teacher" do
      let(:teacher) { create :teacher }

      before do
        login_as teacher
        visit noun_path(word)
      end

      it "does not show change history" do
        expect(page).not_to have_content t("words.versions.title")
      end
    end

    context "when logged in as an admin" do
      let(:admin) { create :user, role: "Admin" }

      before do
        login_as admin
        visit noun_path(word)
      end

      it "shows change history" do
        expect(page).to have_content t("words.versions.title")
      end
    end
  end
end
