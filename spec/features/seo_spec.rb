# frozen_string_literal: true

RSpec.describe "SEO" do
  describe "Word Index" do
    let!(:noun) { create :noun, name: "Adler", plural: "Adler", genus_id: 0 }
    let!(:adjective) { create :adjective, name: "betroffen", comparative: "betroffener", superlative: "betroffensten" }
    let!(:verb) { create :verb, name: "dulden", past_singular_1: "duldete" }

    it "lists all words for the respective letter" do
      visit word_index_path(letter: "a")
      expect(page).to have_selector "li", text: "#{noun.name}, #{noun.article_definite(case_number: 1, singular: true)} - #{noun.plural}, #{noun.article_definite(case_number: 1, singular: false)}"

      visit word_index_path(letter: "b")
      expect(page).to have_selector "li", text: "#{adjective.name}, #{adjective.comparative}, #{adjective.superlative}"

      visit word_index_path(letter: "d")
      expect(page).to have_selector "li", text: "#{verb.name}, #{verb.past_singular_1}"
    end
  end
end
