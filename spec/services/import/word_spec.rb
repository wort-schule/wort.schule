# frozen_string_literal: true

require "rails_helper"

RSpec.describe Import::Word do
  subject { described_class.new(name:, topic:, word_type:).call }

  let(:name) { "Katze" }
  let(:topic) { "Tiere" }
  let(:word_type) { "Noun" }

  context "with an empty database" do
    it "creates a word import" do
      expect { subject }
        .to change(WordImport, :count).by(1)

      expect(WordImport.last).to have_attributes(
        name:,
        topic:,
        word_type:,
        state: "new"
      )
    end
  end

  context "with the same word import" do
    let!(:word_import) { create(:word_import, name:, topic:, word_type:) }

    it "does not do anything" do
      expect { subject }
        .not_to change(WordImport, :count)
    end
  end

  context "with a failed word import" do
    let!(:word_import) { create(:word_import, name:, topic:, word_type:, state: :failed) }

    it "creates a word import" do
      expect { subject }
        .to change(WordImport, :count).by(1)
    end
  end

  context "with the same word" do
    let!(:word) { create(:noun, name:, topics: [build(:topic, name: topic)]) }

    it "enriches the word" do
      expect(Llm::Enrich).to receive(:new).with(word:).and_call_original
      expect_any_instance_of(Llm::Enrich).to receive(:call)

      expect { subject }
        .to change(WordImport, :count).by(1)
    end
  end
end
