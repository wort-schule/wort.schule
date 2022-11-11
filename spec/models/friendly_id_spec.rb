# frozen_string_literal: true

RSpec.describe "friendly ID" do
  describe "URL generation" do
    let(:noun) { create :noun, name: "Bauer" }

    before do
      Rails.application.routes.default_url_options = {host: "example.com"}
    end

    it "creates URLs without controller" do
      expect(Rails.application.routes.url_helpers.url_for(noun)).to eq "http://example.com/bauer"
    end
  end

  context "with unique slugs" do
    let(:noun) { create :noun, name: "Bauer" }

    it "creates a slug" do
      expect(noun.slug).to eq "bauer"
      expect(Noun.find("bauer")).to eq noun
    end
  end

  context "with multiple equal slugs with different topics" do
    let(:noun1) { create :noun, name: "Bauer" }
    let(:noun2) { create :noun, name: "Bauer" }
    let(:noun3) { create :noun, name: "Bauer" }

    it "adds the topic to further slugs" do
      expect(noun1.slug).to eq "bauer"
      expect(noun2.slug).to eq "bauer-2"
      expect(noun3.slug).to eq "bauer-3"
    end
  end

  describe "update a slug" do
    let(:noun) { create :noun, name: "Bauer" }

    it "lowercases the slug" do
      expect(noun.slug).to eq "bauer"

      noun.update!(slug: "ADLer")

      expect(noun.slug).to eq "adler"
    end
  end
end
