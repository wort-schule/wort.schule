# frozen_string_literal: true

require "test_helper"

class HistoryTest < ActiveSupport::TestCase
  setup do
    @word = create(:noun, name: "Adler")
  end

  test "tracks a change of the name itself" do
    @word.update!(name: "Haus")

    assert_equal 2, @word.versions.count

    created_version = @word.versions.find { |version| version.event == "create" }
    updated_version = @word.versions.find { |version| version.event == "update" }

    refute_empty created_version.changeset
    refute_empty updated_version.changeset

    assert_equal({
      "consonant_vowel" => ["VKKVK", "KVVK"],
      "name" => ["Adler", "Haus"],
      "cologne_phonetics" => [["0257"], ["08"]]
    }, updated_version.changeset.except("updated_at"))
  end

  test "tracks a change of an example sentence" do
    assert_equal 1, @word.versions.count
    assert_equal [], @word.example_sentences

    @word.update!(example_sentences: ["Ein Adler fliegt."])
    @word.reload
    assert_equal ["Ein Adler fliegt."], @word.example_sentences
    assert_equal 2, @word.versions.count

    @word.update!(example_sentences: ["Ein Adler fliegt.", "Ein Adler sitzt."])
    @word.reload
    assert_equal ["Ein Adler fliegt.", "Ein Adler sitzt."].sort, @word.example_sentences.sort
    assert_equal 3, @word.versions.count

    @word.update!(example_sentences: ["Ein Adler sitzt."])
    @word.reload
    assert_equal ["Ein Adler sitzt."], @word.example_sentences
    assert_equal 4, @word.versions.count
  end
end
