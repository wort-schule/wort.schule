# frozen_string_literal: true

RSpec.describe "flash cards" do
  it "creates flash card lists when user is created" do
    user = create :guest

    expect(user.lists.unscoped.map(&:flashcard_section)).to match_array (1..5).to_a
    expect(user.lists.unscoped.map(&:to_s)).to match_array ["Fach 1", "Fach 2", "Fach 3", "Fach 4", "Fach 5"]
  end

  describe "adding words to the flash card lists" do
    let(:lecturer) { create :lecturer }
    let!(:learning_group) { create :learning_group, owner: lecturer }
    let(:word_list) { create :list, user: lecturer, visibility: :public }
    let(:user) { create :guest }
    let(:noun1) { create :noun, name: "Adler" }
    let(:noun2) { create :noun, name: "Wolke" }

    before do
      word_list.words << noun1
      word_list.words << noun2
      LearningGroupMembership.create!(learning_group:, user:, access: :granted)
      login_as lecturer
    end

    it "adds words to the first section and removes the word when list is removed" do
      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      login_as user
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name

      # Remove list
      login_as lecturer
      visit learning_group_path(learning_group)
      within "##{dom_id(learning_group.learning_pleas.first)}" do
        click_on t("actions.remove")
      end

      login_as user
      visit flashcards_path
      expect(page).not_to have_content noun1.name
      expect(page).not_to have_content noun2.name
    end

    it "adds and removes words when modifying the list" do
      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      # Add new word
      noun3 = create :noun, name: "Baum"
      visit noun_path(noun3)
      select word_list.name
      click_on I18n.t("words.show.lists.add")

      login_as user
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
      expect(page).to have_content noun3.name

      # Remove word from list
      login_as lecturer
      visit list_path(word_list)
      within "##{dom_id(noun3)}" do
        click_on I18n.t("actions.remove")
      end

      login_as user
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
      expect(page).not_to have_content noun3.name
    end
  end

  describe "add/remove users modifies their words" do
    let(:lecturer) { create :lecturer }
    let!(:learning_group) { create :learning_group, owner: lecturer }
    let(:word_list) { create :list, user: lecturer, visibility: :public }
    let(:user) { create :guest }
    let(:noun1) { create :noun, name: "Adler" }
    let(:noun2) { create :noun, name: "Wolke" }

    before do
      word_list.words << noun1
      word_list.words << noun2
      login_as lecturer
    end

    it "removes words when removing a user" do
      LearningGroupMembership.create!(learning_group:, user:, access: :granted)

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      # Remove user
      login_as lecturer
      visit learning_group_path(learning_group)
      within "##{dom_id(user)}" do
        click_on t("actions.remove")
      end

      user.reload
      expect(user.flashcard_list(1).words).to be_empty

      login_as user
      visit flashcards_path
      expect(page).not_to have_content noun1.name
      expect(page).not_to have_content noun2.name
    end

    it "adds words when adding a user" do
      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]

      # Add user
      click_on t("learning_groups.show.assign_user")
      fill_in t("activerecord.attributes.learning_group_membership.user"), with: user.email
      click_on t("learning_group_memberships.new.assign")

      # User accepts invitation
      login_as user
      visit profile_path
      click_on t("profiles.show.accept")

      user.reload
      expect(user.learning_group_memberships).to be_present
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
    end

    it "does not remove a word when it is also in another learning group" do
      LearningGroupMembership.create!(learning_group:, user:, access: :granted)

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      other_learning_group = create(:learning_group, owner: lecturer)
      other_word_list = create(:list, user: lecturer, visibility: :public)
      other_word_list.words << noun1
      LearningGroupMembership.create!(learning_group: other_learning_group, user:, access: :granted)

      visit learning_group_path(other_learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      within "##{dom_id(other_word_list)}" do
        click_on t("learning_pleas.new.assign")
      end

      expect(other_learning_group.lists).to match_array [other_word_list]
      expect(user.flashcard_list(1).words).to match_array [noun1, noun2]

      # Remove user
      login_as lecturer
      visit learning_group_path(learning_group)
      within "##{dom_id(user)}" do
        click_on t("actions.remove")
      end

      user.reload
      expect(user.flashcard_list(1).words).to match_array [noun1]

      login_as user
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).not_to have_content noun2.name
    end

    it "adds words when generating a user" do
      expect(learning_group.users).to be_empty

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]

      # Generate user
      click_on t("learning_groups.show.generate_accounts")
      fill_in t("learning_groups.user_generations.new.amount"), with: "1"
      click_on t("actions.create")

      generated_user = learning_group.users.first
      expect(generated_user).to be_confirmed
      expect(generated_user.flashcard_list(1).words).to match_array [noun1, noun2]

      login_as generated_user
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
    end
  end
end
