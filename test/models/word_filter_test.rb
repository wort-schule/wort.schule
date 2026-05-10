# frozen_string_literal: true

require "test_helper"

class WordFilterTest < ActiveSupport::TestCase
  setup do
    @abfall = create(:noun, name: "Abfall")
    @abend = create(:noun, name: "Abend")
    @bach = create(:noun, name: "Bach")

    @abfall.keywords << @bach
    @abfall.save!
  end

  test "filters words by keyword using the filter_keywords scope" do
    result = Word.filter_keywords(keywords: [@bach.id])

    assert_includes result, @abfall
    refute_includes result, @abend
    refute_includes result, @bach
  end

  test "filters words with multiple keywords using OR conjunction" do
    katze = create(:noun, name: "Katze")
    @abend.keywords << katze
    @abend.save!

    result = Word.filter_keywords(keywords: [@bach.id, katze.id], conjunction: "or")

    assert_includes result, @abfall
    assert_includes result, @abend
    refute_includes result, @bach
    refute_includes result, katze
  end

  test "filters words with multiple keywords using AND conjunction" do
    katze = create(:noun, name: "Katze")
    @abfall.keywords << katze
    @abfall.save!

    @abend.keywords << katze
    @abend.save!

    result = Word.filter_keywords(keywords: [@bach.id, katze.id], conjunction: "and")

    assert_includes result, @abfall
    refute_includes result, @abend
  end
end
