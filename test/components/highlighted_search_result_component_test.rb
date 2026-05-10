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
end
