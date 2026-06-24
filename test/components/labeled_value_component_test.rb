# frozen_string_literal: true

require "test_helper"

class LabeledValueComponentTest < ApplicationViewComponentTestCase
  test "renders the label and value" do
    render_inline(LabeledValueComponent.new(label: "Genus", value: "der"))

    assert_text "Genus"
    assert_text "der"
  end

  test "renders block content when no value is given" do
    render_inline(LabeledValueComponent.new(label: "Genus")) { "maskulin" }

    assert_text "Genus"
    assert_text "maskulin"
  end

  test "does not render without a label" do
    render_inline(LabeledValueComponent.new(label: "", value: "der"))

    assert_no_text "der"
  end
end
