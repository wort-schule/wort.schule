# frozen_string_literal: true

RSpec.describe "flashcards" do
  context "with the same word on multiple lists" do
    let!(:learning_group) { create :learning_group }
    let(:list1) { create :list }
    let(:list2) { create :list }
    let(:student) { create :student }
    let(:noun1) { create :noun, name: "Adler" }
    let(:noun2) { create :noun, name: "Bauer" }

    before do
      list1.words << [noun1, noun2]
      list2.words << [noun1]
      learning_group.lists << [list1, list2]
      LearningGroupMembership.create!(learning_group:, student:, access: :granted)
    end

    it "adds the word only once" do
      expect(student.first_flashcard_list.words).to be_empty

      Flashcards.add_list(learning_group, list1)
      expect(student.first_flashcard_list.words).to match_array [noun1, noun2]

      Flashcards.add_list(learning_group, list2)
      expect(student.first_flashcard_list.words).to match_array [noun1, noun2]
    end

    it "does not add the word when it is already in another flashcard section" do
      student.flashcard_list(Flashcards::SECTIONS.second).words << noun1
      expect(student.first_flashcard_list.words).to be_empty
      expect(student.flashcard_list(Flashcards::SECTIONS.second).words).to match_array [noun1]

      Flashcards.add_list(learning_group, list2)
      expect(student.first_flashcard_list.words).to be_empty
      expect(student.flashcard_list(Flashcards::SECTIONS.second).words).to match_array [noun1]

      Flashcards.add_list(learning_group, list1)
      expect(student.first_flashcard_list.words).to match_array [noun2]
      expect(student.flashcard_list(Flashcards::SECTIONS.second).words).to match_array [noun1]
    end

    it "removes a word from the first section" do
      expect(student.first_flashcard_list.words).to be_empty

      Flashcards.add_list(learning_group, list1)
      Flashcards.add_list(learning_group, list2)
      expect(student.first_flashcard_list.words).to match_array [noun1, noun2]

      # Do not remove word here, because it is still present on list2
      list1.words.delete(noun1)
      Flashcards.remove_word(list1, noun1)
      expect(student.first_flashcard_list.words).to match_array [noun1, noun2]

      # Now it is removed everywhere
      list2.words.delete(noun1)
      Flashcards.remove_word(list2, noun1)
      expect(student.first_flashcard_list.words).to match_array [noun2]
    end
  end
end
