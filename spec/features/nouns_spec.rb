# frozen_string_literal: true

RSpec.describe "nouns" do
  describe "managing nouns" do
    it_behaves_like "CRUD", Noun
  end

  it_behaves_like "TTS", Noun

  describe "word URLs" do
    let!(:noun) { create :noun, name: "Adler" }

    it "matches word case insensitive" do
      visit "/Adler"
      expect(page).to have_current_path "/adler"
      expect(page).to have_selector "h1", text: "Adler"

      visit "/adler"
      expect(page).to have_current_path "/adler"
      expect(page).to have_selector "h1", text: "Adler"

      visit "/AdLEr"
      expect(page).to have_current_path "/adler"
      expect(page).to have_selector "h1", text: "Adler"
    end

    it "does not redirect routes below the scope 'seite'" do
      expect do
        visit "/seite/IMPRESSUM"
      end.to raise_error ActionController::RoutingError
      expect(page).to have_current_path "/seite/IMPRESSUM"

      visit "/seite/impressum"
      expect(page).to have_current_path "/seite/impressum"

      expect do
        visit "/seite/NoUNs"
      end.to raise_error ActionController::RoutingError
      expect(page).to have_current_path "/seite/NoUNs"
    end

    it "distinguishes between the word 'Seite' and the scope" do
      create :noun, name: "Seite"

      visit "/seite"
      expect(page).to have_current_path "/seite"
      expect(page).to have_selector "h1", text: "Seite"

      visit "/seite/nouns"
      expect(page).to have_current_path "/seite/nouns"
      expect(page).to have_selector "h1", text: Noun.model_name.human(count: 2)
    end
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

  describe "hit counter" do
    let(:noun) { create :noun, name: "Ticken" }
    let(:student) { create :student }

    it "updates the hit counter" do
      expect(noun.hit_counter).to eq 0
      expect(noun.versions.count).to eq 1

      # Update the counter as a guest
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 1

      # Subsequent visits don't update the counter
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 1

      # We need to reset sessions here to simulate another browser/user
      Capybara.reset_sessions!

      login_as student
      # Another user increases the counter again
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 2

      # Visiting again does not increase the counter
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 2

      logout
      # After log out, counter is increased again
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 3

      # We don't want to create a new PaperTrail version for every hit
      expect(noun.versions.count).to eq 1
    end

    it "ignores hits from bots" do
      # Bot user agent
      page.driver.header("User-Agent", "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
      expect(noun.reload.hit_counter).to eq 0
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 0

      # Normal user agent
      page.driver.header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")
      expect(noun.reload.hit_counter).to eq 0
      visit noun_path(noun)
      expect(noun.reload.hit_counter).to eq 1
    end
  end
end
