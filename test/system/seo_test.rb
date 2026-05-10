# frozen_string_literal: true

require "application_system_test_case"

class SeoTest < ApplicationSystemTestCase
  test "Word Index lists all words for the respective letter" do
    noun = create(:noun, name: "Adler", plural: "Adler", genus_id: 0)
    adjective = create(:adjective, name: "betroffen", comparative: "betroffener", superlative: "betroffensten")
    verb = create(:verb, name: "dulden", past_singular_1: "duldete")

    visit word_index_path(letter: "a")
    assert_selector "li", text: "#{noun.name}, #{noun.article_definite(case_number: 1, singular: true)}"
    assert_selector "li", text: "#{noun.plural}, #{noun.article_definite(case_number: 1, singular: false)}"

    visit word_index_path(letter: "b")
    assert_selector "li", text: adjective.name.to_s
    assert_selector "li", text: adjective.comparative.to_s
    assert_selector "li", text: adjective.superlative.to_s

    visit word_index_path(letter: "d")
    assert_selector "li", text: verb.name.to_s
    assert_selector "li", text: verb.past_singular_1.to_s
  end
end
