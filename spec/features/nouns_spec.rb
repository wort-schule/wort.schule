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

  describe "shows more meanings" do
    let(:noun) { create :noun, name: "Ticken" }
    let(:more_meanings) { I18n.t("words.show.general.more_meanings", count: 1) }

    context "with a unique word" do
      it "does not show another meaning" do
        visit noun_path(noun)

        expect(page).not_to have_content more_meanings
      end
    end

    context "with same spelling" do
      let!(:verb) { create :noun, name: "ticken" }

      it "shows another meaning" do
        visit noun_path(noun)

        expect(page).to have_content more_meanings
        click_on more_meanings

        expect(page).to have_current_path search_path(filterrific: {filter_wordstarts: "Ticken"})
        within("##{dom_id(noun)}") do
          expect(page).to have_content "Ticken"
        end
        within("##{dom_id(verb)}") do
          expect(page).to have_content "ticken"
        end
      end
    end
  end
end
