# frozen_string_literal: true

RSpec::Matchers.define :have_open_graph do |name, expected|
  match do |actual|
    element = find("meta[property='#{name}']", visible: false)

    element && (expected.is_a?(Regexp) ? expected.match(element[:content]) : element[:content] == expected)
  rescue Capybara::ElementNotFound
    false
  end

  failure_message do |actual|
    actual_element = first("meta[property='#{name}']", visible: false)

    if actual_element
      "expected that meta #{name} would have content='#{expected}' but was '#{actual_element[:content]}'"
    else
      "expected that meta #{name} would exist with content='#{expected}'"
    end
  end
end
