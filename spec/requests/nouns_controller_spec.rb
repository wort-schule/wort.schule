# frozen_string_literal: true

RSpec.describe NounsController, type: :request do
  let(:admin) { create :admin }
  let(:word) { create :noun }
  let(:compound_preconfix) { create :compound_preconfix }
  let(:compound_postconfix) { create :compound_postconfix }

  before do
    sign_in admin
  end

  describe "#create" do
    it "assigns compound entities" do
      post nouns_path, params: {
        noun: {
          name: "Compound Test",
          compound_entity_ids: [
            "Word:#{word.id}",
            "CompoundPreconfix:#{compound_preconfix.id}",
            "CompoundPostconfix:#{compound_postconfix.id}"
          ]
        }
      }

      noun = Noun.last
      expect(noun.name).to eq "Compound Test"

      entities = noun
        .compound_entities
        .order(:pos)
        .pluck(:word_id, :part_id, :part_type, :pos)

      expect(entities).to match [
        [noun.id, word.id, "Word", 1],
        [noun.id, compound_preconfix.id, "CompoundPreconfix", 2],
        [noun.id, compound_postconfix.id, "CompoundPostconfix", 3]
      ]
    end
  end

  describe "#update" do
    let(:noun) { create :noun }

    before do
      noun.compound_entities << CompoundEntity.create(word: noun, part: word, pos: 1)
      noun.compound_entities << CompoundEntity.create(word: noun, part: compound_preconfix, pos: 2)
      noun.compound_entities << CompoundEntity.create(word: noun, part: compound_postconfix, pos: 3)
    end

    it "removes a compound entity" do
      patch noun_path(noun), params: {
        noun: {
          compound_entity_ids: [
            "Word:#{word.id}",
            "CompoundPostconfix:#{compound_postconfix.id}"
          ]
        }
      }

      noun.reload

      entities = noun
        .compound_entities
        .order(:pos)
        .pluck(:word_id, :part_id, :part_type, :pos)

      expect(entities).to match [
        [noun.id, word.id, "Word", 1],
        [noun.id, compound_postconfix.id, "CompoundPostconfix", 2]
      ]
    end

    it "allows IDs of compound entities to be sent" do
      patch noun_path(noun), params: {
        noun: {
          compound_entity_ids: [
            noun.compound_entities.first.id.to_s,
            noun.compound_entities.third.id.to_s
          ]
        }
      }

      noun.reload

      entities = noun
        .compound_entities
        .order(:pos)
        .pluck(:word_id, :part_id, :part_type, :pos)

      expect(entities).to match [
        [noun.id, word.id, "Word", 1],
        [noun.id, compound_postconfix.id, "CompoundPostconfix", 2]
      ]
    end
  end

  describe "images" do
    before do
      word.image.attach(
        io: StringIO.new(File.read("spec/fixtures/files/avatar1.png")),
        filename: "example.png"
      )

      ActiveStorage::Current.url_options = {host: "localhost"}
    end

    it "loads images correctly" do
      expect(word.image).to be_attached

      get word.image.url
      expect(response).to be_successful
    end
  end
end
