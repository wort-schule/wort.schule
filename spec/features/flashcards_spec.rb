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

    it "adds words to the first section" do
      word_list.words << noun1
      word_list.words << noun2
      LearningGroupMembership.create!(learning_group:, student:, access: :granted)
      login_as teacher

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
    end
  end
end
