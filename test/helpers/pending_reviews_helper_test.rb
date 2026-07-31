# frozen_string_literal: true

require "test_helper"

class PendingReviewsHelperTest < ActionView::TestCase
  test "joins array values with a comma and stringifies non-string elements" do
    assert_equal "1, 2, 3", truncate_value([1, 2, 3])
    assert_equal "a, b", truncate_value(["a", "b"])
  end

  test "truncates long values" do
    assert_equal 40, truncate_value("x" * 100).length
    assert_equal 40, truncate_value(Array.new(20) { "long" }).length
  end

  test "stringifies values that are neither string nor array" do
    assert_equal "42", truncate_value(42)
    assert_equal "", truncate_value(nil)
  end
end
