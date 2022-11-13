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

    it "copies an existing theme" do
      visit theme_path(entry)

      click_on t("actions.copy")

      expect do
        click_on t("helpers.submit.create")
      end.to change(Theme, :count).by 1

      theme = Theme.find_by(name: "Kopie von #{entry.name}")

      expect(theme.description).to eq entry.description
      expect(theme.template.gsub("\r\n", "\n")).to eq entry.template
      expect(theme.word_type).to eq entry.word_type
      expect(theme.visibility).to eq :private
      expect(theme.user).to eq User.find(admin.id)
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

  describe "set default theme in profile" do
    let!(:noun_theme) { create :theme, word_type: :noun, name: "Nomenkarte" }
    let!(:verb_theme) { create :theme, word_type: :verb, name: "Verbenkarte" }

    context "with a different theme set" do
      before do
        admin.update!(theme_noun: noun_theme)
      end

      it "sets standard theme for nouns" do
        expect(admin.theme_noun).not_to be_nil
        expect(admin.theme_verb).to be_nil

        visit profile_path

        within ".ci-theme-noun" do
          click_on I18n.t("actions.change")
        end

        expect(page).to have_content noun_theme.name
        expect(page).not_to have_content verb_theme.name

        within "#theme_0" do
          click_on I18n.t("theme_select_component.select")
        end

        expect(page).to have_current_path profile_path
        expect(admin.reload.theme_noun).to be_nil
      end
    end

    context "with default theme set" do
      it "sets another theme for verbs" do
        expect(admin.theme_noun).to be_nil
        expect(admin.theme_verb).to be_nil

        visit profile_path

        within ".ci-theme-verb" do
          click_on I18n.t("actions.change")
        end

        expect(page).not_to have_content noun_theme.name
        expect(page).to have_content verb_theme.name

        within "##{dom_id(verb_theme)}" do
          click_on I18n.t("theme_select_component.select")
        end

        expect(page).to have_current_path profile_path

        admin.reload
        expect(admin.theme_noun).to be_nil
        expect(admin.theme_verb).to eq verb_theme
      end
    end
  end
end
