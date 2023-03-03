# frozen_string_literal: true

require "rails_helper"

RSpec.describe HighlightedSearchResultComponent, type: :component do
  it "splits results correctly" do
    # Start
    expect(described_class.new(result: "Haus", query: "ha").parts).to eq %w[Ha us]
    # Middle
    expect(described_class.new(result: "Bauhaus", query: "ha").parts).to eq %w[Bau ha us]
    # End
    expect(described_class.new(result: "Bauhaus", query: "aus").parts).to eq %w[Bauh aus]
    # Multiple
    expect(described_class.new(result: "Bauhaus", query: "au").parts).to eq %w[B au h au s]
    # Complete word
    expect(described_class.new(result: "Haus", query: "haus").parts).to eq %w[Haus]
    # Regex
    expect(described_class.new(result: "Haus", query: "h.").parts).to eq %w[Haus]
  end
end
