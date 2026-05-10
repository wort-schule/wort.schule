# frozen_string_literal: true

module OpenGraphAssertions
  def assert_open_graph(name, expected)
    element = first("meta[property='#{name}']", visible: false)
    flunk "expected meta property #{name.inspect} with content #{expected.inspect}, but no such tag was found" unless element

    actual = element[:content]
    matched = expected.is_a?(Regexp) ? expected.match?(actual) : actual == expected
    assert matched,
      "expected meta property #{name.inspect} with content #{expected.inspect}, got #{actual.inspect}"
  end
end
