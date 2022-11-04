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
    let(:noun2) { create :noun, name: "Bauer", topic_ids: [topic2.id] }
    let(:noun3) { create :noun, name: "Bauer", topic_ids: [topic3.id, topic4.id] }

    let(:topic2) { create :topic, name: "Schach" }
    let(:topic3) { create :topic, name: "Bauernhof" }
    let(:topic4) { create :topic, name: "Teekesselchen" }

    it "adds the topic to further slugs" do
      expect(noun1.slug).to eq "bauer"
      expect(noun2.slug).to eq "bauer-schach"
      expect(noun3.slug).to eq "bauer-bauernhof-teekesselchen"
    end
  end

  context "with multiple equal slugs with no topics" do
    let(:noun1) { create :noun, name: "Bauer" }
    let(:noun2) { create :noun, name: "Bauer" }
    let(:noun3) { create :noun, name: "Bauer" }

    it "adds a sequential ID to further slugs" do
      expect(noun1.slug).to eq "bauer"
      expect(noun2.slug).to eq "bauer-2"
      expect(noun3.slug).to eq "bauer-3"
    end
  end

  context "with multiple equal slugs with same topics" do
    let(:noun1) { create :noun, name: "Bauer", topic_ids: [topic2.id, topic3.id] }
    let(:noun2) { create :noun, name: "Bauer", topic_ids: [topic2.id, topic3.id] }
    let(:noun3) { create :noun, name: "Bauer", topic_ids: [topic2.id, topic3.id] }
    let(:noun4) { create :noun, name: "Bauer", topic_ids: [topic2.id, topic3.id] }

    let(:topic2) { create :topic, name: "Schach" }
    let(:topic3) { create :topic, name: "Bauernhof" }

    it "adds the topic or sequential ID to further slugs" do
      expect(noun1.slug).to eq "bauer"
      expect(noun2.slug).to eq "bauer-schach-bauernhof"
      expect(noun3.slug).to eq "bauer-2"
      expect(noun4.slug).to eq "bauer-3"
    end
  end
end
