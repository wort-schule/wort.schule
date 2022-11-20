# frozen_string_literal: true

RSpec.describe "flash cards" do
  it "creates flash card lists when student is created" do
    student = create :student

    expect(student.lists.unscoped.map(&:flashcard_section)).to match_array (1..5).to_a
    expect(student.lists.unscoped.map(&:to_s)).to match_array ["Fach 1", "Fach 2", "Fach 3", "Fach 4", "Fach 5"]
  end

  describe "adding words to the flash card lists" do
    let(:teacher) { create :teacher }
    let(:school) { create :school }
    let!(:teaching_assignment) { create :teaching_assignment, teacher:, school: }
    let!(:learning_group) { create :learning_group, teacher:, school: }
    let(:word_list) { create :list, user: teacher, visibility: :public }
    let(:student) { create :student }
    let(:noun1) { create :noun, name: "Adler" }
    let(:noun2) { create :noun, name: "Bauer" }

    before do
      word_list.words << noun1
      word_list.words << noun2
      LearningGroupMembership.create!(learning_group:, student:, access: :granted)
      login_as teacher
    end

    it "adds words to the first section and removes the word when list is removed" do
      visit school_learning_group_path(school, learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(student.flashcard_list(1).words).to match_array [noun1, noun2]

      login_as student
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name

      # Remove list
      login_as teacher
      visit school_learning_group_path(school, learning_group)
      within "##{dom_id(learning_group.learning_pleas.first)}" do
        click_on t("actions.remove")
      end

      login_as student
      visit flashcards_path
      expect(page).not_to have_content noun1.name
      expect(page).not_to have_content noun2.name
    end

    it "adds and removes words when modifying the list" do
      visit school_learning_group_path(school, learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")
      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
      expect(student.flashcard_list(1).words).to match_array [noun1, noun2]

      # Add new word
      noun3 = create :noun, name: "Baum"
      visit noun_path(noun3)
      select word_list.name
      click_on I18n.t("words.show.lists.add")

      login_as student
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
      expect(page).to have_content noun3.name

      # Remove word from list
      login_as teacher
      visit list_path(word_list)
      within "##{dom_id(noun3)}" do
        click_on I18n.t("actions.remove")
      end

      login_as student
      visit flashcards_path
      expect(page).to have_content noun1.name
      expect(page).to have_content noun2.name
      expect(page).not_to have_content noun3.name
    end
  end
end
