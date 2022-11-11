# frozen_string_literal: true

RSpec.describe "themes for words" do
  let(:klass) { Theme }
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  context "with existing entries" do
    let!(:entry) { create klass.model_name.singular }

    it "shows existing entries" do
      visit public_send("#{klass.model_name.plural}_path")

      expect(page).to have_content entry.name
    end

    it "edits an entry" do
      visit public_send("#{klass.model_name.plural}_path")

      click_on entry.name
      click_on t("actions.edit")
      fill_in "#{klass.model_name.singular}[name]", with: "Anderer Name"
      click_on t("helpers.submit.update")

      entry.reload
      expect(entry.name).to eq "Anderer Name"
    end

    it "shows an error when invalid" do
      visit public_send("#{klass.model_name.plural}_path")

      click_on entry.name
      click_on t("actions.edit")
      fill_in "#{klass.model_name.singular}[name]", with: ""

      expect do
        click_on t("helpers.submit.update")
      end.not_to change(klass, :count)

      expect(page).to have_content t("errors.messages.blank")
    end

    it "deletes an entry" do
      visit public_send("#{klass.model_name.plural}_path")

      click_on entry.name
      click_on t("actions.edit")
      click_on t("actions.delete")

      expect do
        entry.reload
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "without existing entries" do
    it "creates an entry" do
      visit public_send("#{klass.model_name.plural}_path")
      click_on t("#{klass.model_name.plural}.index.new")

      fill_in "#{klass.model_name.singular}[name]", with: "Neuer Name"
      fill_in "#{klass.model_name.singular}[template]", with: "Template Test"

      expect do
        click_on t("helpers.submit.create")
      end.to change(klass, :count).by 1

      expect(klass.last.name).to eq "Neuer Name"
      expect(klass.last.template).to eq "Template Test"
    end

    it "shows an error when invalid" do
      visit public_send("#{klass.model_name.plural}_path")
      click_on t("#{klass.model_name.plural}.index.new")

      expect do
        click_on t("helpers.submit.create")
      end.not_to change(klass, :count)

      expect(page).to have_content t("errors.messages.blank")
    end

    it "does not allow JavaScript content", js: true do
      visit public_send("#{klass.model_name.plural}_path")
      click_on t("#{klass.model_name.plural}.index.new")

      fill_in "#{klass.model_name.singular}[name]", with: "Neuer Name"
      fill_in "#{klass.model_name.singular}[template]", with: "Template <script>document.write('hello world')</script>"

      expect do
        click_on t("helpers.submit.create")
      end.to change(klass, :count).by 1

      new_theme = klass.last
      expect(new_theme.name).to eq "Neuer Name"
      expect(new_theme.word_type).to eq "noun"

      admin.update(theme_noun: new_theme)

      visit noun_path(create(:noun))
      expect(page).to have_content "Template"
      expect(page).not_to have_content "hello world"
    end
  end
end
