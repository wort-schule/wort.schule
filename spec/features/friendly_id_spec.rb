# frozen_string_literal: true

RSpec.describe "friendly ID" do
  let(:noun) { create :noun, name: "Ticken" }
  let(:verb) { create :noun, name: "ticken" }
  let(:admin) { create :user, role: "Admin" }

  before do
    login_as admin
  end

  describe "edit a slug" do
    it "allows to edit a slug" do
      expect(noun.slug).to eq "ticken"
      expect(verb.slug).to eq "ticken-2"

      visit edit_verb_path(verb)
      expect(page).to have_field t("activerecord.attributes.word.slug"), with: "ticken-2"
      fill_in t("activerecord.attributes.word.slug"), with: "ticken-verb"
      click_on t("helpers.submit.update")

      expect(verb.reload.slug).to eq "ticken-verb"
    end
  end
end
