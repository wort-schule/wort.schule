# frozen_string_literal: true

RSpec.describe "word view settings" do
  it_behaves_like "CRUD", WordViewSetting

  let!(:admin) { create(:user, role: "Admin") }
  let!(:lecturer) { create(:user, role: "Lecturer") }
  let!(:public_word_view_setting) { create(:word_view_setting, owner: admin, visibility: :public) }
  let!(:private_word_view_setting_of_admin) { create(:word_view_setting, owner: admin, visibility: :private) }
  let!(:private_word_view_setting_of_lecturer) { create(:word_view_setting, owner: lecturer, visibility: :private) }

  context "as an admin" do
    before { login_as admin }

    it "shows private word view settings from other users" do
      visit word_view_settings_path

      expect(page).to have_content public_word_view_setting.name
      expect(page).to have_content private_word_view_setting_of_admin.name
      expect(page).to have_content private_word_view_setting_of_lecturer.name
    end
  end

  context "as a lecturer" do
    before { login_as lecturer }

    it "shows only my own private word view settings" do
      visit word_view_settings_path

      expect(page).to have_content public_word_view_setting.name
      expect(page).not_to have_content private_word_view_setting_of_admin.name
      expect(page).to have_content private_word_view_setting_of_lecturer.name
    end
  end
end
