# frozen_string_literal: true

RSpec.describe "tracking change history" do
  subject(:word) { create :noun, name: "Adler" }

  it "tracks a change of the name itself" do
    word.update!(name: "Haus")

    expect(word.versions.count).to eq 2

    created_version = word.versions.find { |version| version.event == "create" }
    updated_version = word.versions.find { |version| version.event == "update" }

    expect(created_version.changeset).not_to be_empty
    expect(updated_version.changeset).not_to be_empty

    expect(updated_version.changeset.except("updated_at")).to eq({
      "consonant_vowel" => ["VKKVK", "KVVK"],
      "name" => ["Adler", "Haus"],
      "cologne_phonetics" => ["0257", "08"]
    })
  end

  it "tracks a change of an example sentence" do
    expect(word.versions.count).to eq 1
    expect(word.example_sentences).to eq []

    # Add an example sentence
    word.update!(example_sentences: ["Ein Adler fliegt."])
    word.reload
    expect(word.example_sentences).to match_array ["Ein Adler fliegt."]
    expect(word.versions.count).to eq 2

    # Add another sentence
    word.update!(example_sentences: ["Ein Adler fliegt.", "Ein Adler sitzt."])
    word.reload
    expect(word.example_sentences).to match_array ["Ein Adler fliegt.", "Ein Adler sitzt."]
    expect(word.versions.count).to eq 3

    # Delete the example sentence
    word.update!(example_sentences: ["Ein Adler sitzt."])
    word.reload
    expect(word.example_sentences).to match_array ["Ein Adler sitzt."]
    expect(word.versions.count).to eq 4
  end
end
