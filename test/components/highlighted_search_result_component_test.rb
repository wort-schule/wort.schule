# frozen_string_literal: true

require "test_helper"

class HighlightedSearchResultComponentTest < ApplicationViewComponentTestCase
  test "splits results correctly" do
    # Start
    assert_equal %w[Ha us], HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "ha").parts
    # Middle
    assert_equal %w[Bau ha us], HighlightedSearchResultComponent.new(result: Word.new(name: "Bauhaus"), query: "ha").parts
    # End
    assert_equal %w[Bauh aus], HighlightedSearchResultComponent.new(result: Word.new(name: "Bauhaus"), query: "aus").parts
    # Multiple
    assert_equal %w[B au h au s], HighlightedSearchResultComponent.new(result: Word.new(name: "Bauhaus"), query: "au").parts
    # Complete word
    assert_equal %w[Haus], HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "haus").parts
    # Regex
    assert_equal %w[Haus], HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "h.").parts
    # Noun with article
    assert_equal ["das&nbsp;", "Hau", "s"], HighlightedSearchResultComponent.new(result: Noun.new(name: "Haus", genus_id: 2), query: "hau").parts
  end

  # The query comes straight from the search box, so it must be matched as
  # plain text and never compiled as a regular expression.
  test "treats regexp characters in the query as plain text" do
    assert_nil HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "(").hit_in
    assert_nil HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "h.us").hit_in
    assert_equal :full_name, HighlightedSearchResultComponent.new(result: Word.new(name: "Haus"), query: "AU").hit_in
  end
end
