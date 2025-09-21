require "rails_helper"

RSpec.describe "User Model Performance", type: :model do
  describe "#word_in_flashcards?" do
    let(:user) { create(:user) }
    let(:word) { create(:noun) }
    let(:list) { create(:list, user: user, flashcard_section: "section1") }

    before do
      list.words << word
    end

    it "uses efficient exists? query" do
      expect(user.flashcard_lists).to receive(:joins).with(:words).and_call_original
      expect(user.word_in_flashcards?(word)).to be true
    end

    it "returns false for words not in flashcards" do
      other_word = create(:noun)
      expect(user.word_in_flashcards?(other_word)).to be false
    end
  end
end
