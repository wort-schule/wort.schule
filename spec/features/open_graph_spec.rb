# frozen_string_literal: true

RSpec.describe "open graph tags" do
  it "does not render open graph tags for non-word pages" do
    visit root_path

    expect(page).not_to have_open_graph "og:title"
  end

  it "does not render open graph tags for index pages" do
    visit nouns_path

    expect(page).not_to have_open_graph "og:title"
  end

  context "with a noun having only a name" do
    let(:noun) { create :noun, name: "Abend", meaning_long: nil }

    it "adds a title tag" do
      visit noun_path(noun)

      expect(page).to have_open_graph "og:title", "Abend"
      expect(page).to have_open_graph "og:url", "http://www.example.com/abend"
      expect(page).not_to have_open_graph "og:description"
      expect(page).not_to have_open_graph "og:image"
    end
  end

  context "with a noun with detailed information" do
    let(:noun) { create :noun, name: "Abend", meaning_long: "Tageszeit um die Dämmerung, das Dunkelwerden vor Beginn der Nacht" }

    before do
      noun.update!(
        image: ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(File.read("spec/fixtures/files/avatar1.png")),
          filename: "avatar1.png"
        )
      )
    end

    it "adds multiple tags" do
      visit noun_path(noun)

      expect(page).to have_open_graph "og:title", "Abend"
      expect(page).to have_open_graph "og:description", "Tageszeit um die Dämmerung, das Dunkelwerden vor Beginn der Nacht"
      expect(page).to have_open_graph "og:url", "http://www.example.com/abend"
      expect(page).to have_open_graph "og:image", %r{http://www.example.com/rails/active_storage/.*/avatar1.png}
    end
  end
end
