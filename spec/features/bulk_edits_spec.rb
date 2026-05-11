# frozen_string_literal: true

RSpec.describe "bulk edits" do
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  describe "search" do
    let!(:noun1) { create :noun, name: "Haustier" }
    let!(:noun2) { create :noun, name: "Hausboot" }
    let!(:noun3) { create :noun, name: "Schule" }

    it "finds words by wildcard search" do
      visit bulk_edits_path

      fill_in "q", with: "Haus*"
      click_on t("bulk_edits.index.search_button")

      expect(page).to have_content("Haustier")
      expect(page).to have_content("Hausboot")
      expect(page).not_to have_content("Schule")
    end
  end

  describe "bulk assign phenomenons" do
    let!(:noun1) { create :noun, name: "Haustier" }
    let!(:noun2) { create :noun, name: "Hausboot" }
    let!(:phenomenon) { create :phenomenon, name: "Doppelkonsonanz" }

    it "assigns phenomenons to selected words via service" do
      service = BulkEditService.new(user: admin)
      bulk_edit = service.execute(
        word_ids: [noun1.id, noun2.id],
        field: "phenomenons",
        operation: "add",
        values: [phenomenon.id.to_s],
        search_query: "Haus*"
      )

      expect(noun1.reload.phenomenons).to include(phenomenon)
      expect(noun2.reload.phenomenons).to include(phenomenon)
      expect(bulk_edit.affected_words_count).to eq(2)
    end
  end

  describe "protocol tab" do
    let!(:noun) { create :noun, name: "Haus" }
    let!(:phenomenon) { create :phenomenon, name: "Doppelkonsonanz" }

    it "shows bulk edit in protocol" do
      BulkEditService.new(user: admin).execute(
        word_ids: [noun.id],
        field: "phenomenons",
        operation: "add",
        values: [phenomenon.id.to_s],
        search_query: "Haus"
      )

      visit bulk_edits_path

      expect(page).to have_content(t("bulk_edits.index.tab_log"))
    end
  end

  describe "undo" do
    let!(:noun) { create :noun, name: "Haus" }
    let!(:phenomenon) { create :phenomenon, name: "Doppelkonsonanz" }

    it "undoes a bulk edit via service" do
      service = BulkEditService.new(user: admin)
      bulk_edit = service.execute(
        word_ids: [noun.id],
        field: "phenomenons",
        operation: "add",
        values: [phenomenon.id.to_s]
      )

      expect(noun.reload.phenomenons).to include(phenomenon)

      service.undo(bulk_edit)

      expect(noun.reload.phenomenons).not_to include(phenomenon)
      expect(bulk_edit.reload.undone?).to be true
    end
  end

  describe "authorization" do
    let(:guest) { create :guest }

    it "denies access for non-admins" do
      login_as guest

      expect {
        visit bulk_edits_path
      }.to raise_error(CanCan::AccessDenied)
    end
  end
end
