# frozen_string_literal: true

RSpec.describe "lists" do
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  context "with existing lists" do
    let!(:list) { create :list, user: admin }

    it "shows existing lists" do
      visit lists_path

      expect(page).to have_content list.name
    end

    it "edits an list" do
      visit lists_path

      click_on list.name
      click_on t("actions.edit")
      fill_in "list[name]", with: "Anderer Name"
      click_on t("helpers.submit.update")

      list.reload
      expect(list.name).to eq "Anderer Name"
    end

    it "shows an error when invalid" do
      visit lists_path

      click_on list.name
      click_on t("actions.edit")
      fill_in "list[name]", with: ""

      expect do
        click_on t("helpers.submit.update")
      end.not_to change(List, :count)

      expect(page).to have_content t("errors.messages.blank")
    end

    it "deletes an list" do
      visit lists_path

      click_on list.name
      click_on t("actions.edit")
      click_on t("actions.delete")

      expect do
        list.reload
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "without existing lists" do
    it "creates an list" do
      visit lists_path
      click_on t("lists.index.new")

      fill_in "list[name]", with: "Neuer Name"

      expect do
        click_on t("helpers.submit.create")
      end.to change(List, :count).by 1

      expect(List.last.name).to eq "Neuer Name"
    end

    it "shows an error when invalid" do
      visit lists_path
      click_on t("lists.index.new")

      expect do
        click_on t("helpers.submit.create")
      end.not_to change(List, :count)

      expect(page).to have_content t("errors.messages.blank")
    end
  end
end
