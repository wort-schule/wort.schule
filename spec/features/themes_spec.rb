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
      visit public_send(:"#{klass.model_name.plural}_path")

      expect(page).to have_content entry.name
    end

    it "edits an entry" do
      visit public_send(:"#{klass.model_name.plural}_path")

      click_on entry.name
      click_on t("actions.edit")
      fill_in "#{klass.model_name.singular}[name]", with: "Anderer Name"
      click_on t("helpers.submit.update")

      entry.reload
      expect(entry.name).to eq "Anderer Name"
    end

    it "shows an error when invalid" do
      visit public_send(:"#{klass.model_name.plural}_path")

      click_on entry.name
      click_on t("actions.edit")
      fill_in "#{klass.model_name.singular}[name]", with: ""

      expect do
        click_on t("helpers.submit.update")
      end.not_to change(klass, :count)

      expect(page).to have_content t("errors.messages.blank")
    end

    it "deletes an entry" do
      visit public_send(:"#{klass.model_name.plural}_path")

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
      visit public_send(:"#{klass.model_name.plural}_path")
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
      visit public_send(:"#{klass.model_name.plural}_path")
      click_on t("#{klass.model_name.plural}.index.new")

      expect do
        click_on t("helpers.submit.create")
      end.not_to change(klass, :count)

      expect(page).to have_content t("errors.messages.blank")
    end

    it "does not allow JavaScript content", js: true do
      visit public_send(:"#{klass.model_name.plural}_path")
      click_on t("#{klass.model_name.plural}.index.new")
      click_on t("actions.continue")

      fill_in "#{klass.model_name.singular}[name]", with: "Neuer Name"
      find(".cm-editor").click
      page.driver.browser.keyboard.type "Template <script>document.write('hello world')</script>"

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
    let!(:word_view_setting) { create :word_view_setting, theme_noun: noun_theme, theme_verb: verb_theme, owner: admin }
    let!(:noun_theme) { create :theme, word_type: :noun, name: "Nomenkarte" }
    let!(:verb_theme) { create :theme, word_type: :verb, name: "Verbenkarte" }

    context "with a different theme set" do
      before do
        admin.update!(word_view_setting:)
      end

      it "sets standard settings" do
        expect(admin.word_view_setting).not_to be_nil

        visit profile_path

        expect(page).to have_content word_view_setting.name

        within ".ci-word-view-setting" do
          click_on I18n.t("actions.change")
        end

        select "", from: User.human_attribute_name(:word_view_setting)
        click_on t("helpers.submit.update")

        expect(page).to have_current_path profile_path
        expect(admin.reload.word_view_setting).to be_nil
      end
    end

    context "with default theme set" do
      it "sets other settings" do
        expect(admin.word_view_setting).to be_nil

        visit profile_path

        expect(page).not_to have_content word_view_setting.name

        within ".ci-word-view-setting" do
          click_on I18n.t("actions.change")
        end

        select word_view_setting.name, from: User.human_attribute_name(:word_view_setting)
        click_on t("helpers.submit.update")

        expect(page).to have_current_path profile_path

        admin.reload
        expect(admin.word_view_setting).to eq word_view_setting
      end
    end
  end

  describe "renders words according to theme in profile" do
    let!(:theme) { create :theme, word_type: :noun, name: "Nomenkarte", template: "{{ meaning }}" }
    let(:noun) { create :noun, name: "Bauer", meaning: "Meine Bedeutung" }

    it "renders the correct theme" do
      expect(admin.theme_noun).to be_nil

      # Check if standard template is rendered
      visit noun_path(noun)
      expect(page).to have_content noun.name

      # Change template in profile
      visit profile_path
      within(".ci-theme-noun") { click_on I18n.t("actions.change") }
      within "##{dom_id(theme)}" do
        click_on I18n.t("theme_select_component.select")
      end

      expect(admin.reload.theme_noun).to eq theme

      # Check if new theme is rendered
      visit noun_path(noun)
      expect(page).not_to have_content noun.name
      expect(page).to have_content noun.meaning
    end

    it "always renders the default template for guests" do
      # Template is rendered as admin
      admin.update!(theme_noun: theme)
      visit noun_path(noun)
      expect(page).not_to have_content noun.name
      expect(page).to have_content noun.meaning

      # Renders default view as guest
      logout
      visit noun_path(noun)
      expect(page).to have_content noun.name
    end
  end

  describe "update theme in learning group" do
    let(:learning_group) { create :learning_group }
    let(:user1) { create :guest }
    let!(:user2) { create :guest }
    let!(:word_view_setting) { create :word_view_setting, theme_noun: noun_theme, owner: learning_group.owner }
    let!(:noun_theme) { create :theme, word_type: :noun }
    let!(:membership) do
      create(
        :learning_group_membership,
        user: user1,
        learning_group: learning_group,
        access: :granted
      )
    end

    it "updates the theme for all users" do
      expect(learning_group.reload.word_view_setting).to be_nil
      expect(user1.word_view_setting&.theme_noun).to be_nil
      expect(user2.word_view_setting&.theme_noun).to be_nil

      visit learning_group_path(learning_group)
      expect(page).to have_content user1.full_name
      expect(page).not_to have_content user2.full_name

      click_on I18n.t("actions.edit")

      select word_view_setting.name, from: LearningGroup.human_attribute_name(:word_view_setting)
      click_on I18n.t("actions.save")

      expect(learning_group.reload.word_view_setting).to eq word_view_setting
      expect(user1.reload.word_view_setting).to eq word_view_setting
      expect(user1.reload.word_view_setting.theme_noun).to eq noun_theme
      expect(user2.reload.word_view_setting).to be_nil
    end
  end
end
