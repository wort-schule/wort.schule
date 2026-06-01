# frozen_string_literal: true

require "test_helper"

class ReviewsHelperTest < ActionView::TestCase
  test "orders new words first, then attributes by descending count" do
    user = create(:admin, review_attributes: ["noun.synonyms"], review_new_words: true)
    counts = {"keywords" => 1, "synonyms" => 3, "new_word" => 2}

    segments = review_filter_segments(user, counts)

    assert_equal ["new_word", "synonyms", "keywords"], segments.map { |segment| segment[:review_type] }
  end

  test "marks a segment active when the reviewer selected that type" do
    user = create(:admin, review_attributes: ["noun.synonyms"], review_new_words: true)

    segments = review_filter_segments(user, {"keywords" => 1, "synonyms" => 3})

    assert segments.find { |segment| segment[:review_type] == "synonyms" }[:active]
    refute segments.find { |segment| segment[:review_type] == "keywords" }[:active]
  end

  test "omits the new word segment when its count is absent or zero" do
    user = create(:admin, review_new_words: true)

    assert_empty review_filter_segments(user, {})
    assert_empty review_filter_segments(user, {"new_word" => 0})
  end

  test "shows the new word segment but inactive when the reviewer disabled it" do
    user = create(:admin, review_new_words: false)

    segments = review_filter_segments(user, {"new_word" => 2})

    new_word = segments.find { |segment| segment[:review_type] == "new_word" }
    assert_equal 2, new_word[:count]
    refute new_word[:active]
  end

  test "skips attribute names that are not toggleable review types" do
    user = create(:admin)

    segments = review_filter_segments(user, {"not_a_real_attribute" => 5})

    assert_empty segments
  end

  test "labels attribute segments with their human attribute name" do
    user = create(:admin, review_attributes: [])

    segments = review_filter_segments(user, {"keywords" => 1})

    assert_equal Llm::Attributes.by_attribute_name.dig("keywords", :title), segments.first[:label]
  end
end
