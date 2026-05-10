# frozen_string_literal: true

require "test_helper"

class WordTest < ActiveSupport::TestCase
  test "#syllables_count with an empty string returns 0" do
    word = build(:word)
    word.syllables = ""
    assert_equal 0, word.syllables_count
  end

  test "#syllables_count with whitespaces returns 0" do
    word = build(:word)
    word.syllables = "   "
    assert_equal 0, word.syllables_count
  end

  test "#syllables_count with only one syllable returns 1" do
    word = build(:word)
    word.syllables = "see"
    assert_equal 1, word.syllables_count
  end

  test "#syllables_count with multiple syllables returns 3" do
    word = build(:word)
    word.syllables = "katz-en-baum"
    assert_equal 3, word.syllables_count
  end

  test "#syllables_count with multiple syllables and whitespaces returns 3" do
    word = build(:word)
    word.syllables = " katz-en- baum"
    assert_equal 3, word.syllables_count
  end

  test "#opposites adds a synonym" do
    word = create(:noun, name: "Haus")
    synonym = create(:noun, name: "Gebäude")

    word.synonyms << synonym
    word.reload

    assert_equal [synonym], word.synonyms.to_a
  end

  test "#opposites does not add a duplicate" do
    word = create(:noun, name: "Haus")
    synonym = create(:noun, name: "Gebäude")
    word.synonyms << synonym

    word.synonyms << synonym
    word.reload

    assert_equal [synonym], word.synonyms.to_a
  end

  test "#example_sentences adds a sentence" do
    word = create(:noun, name: "Haus")
    assert_equal true, word.update(example_sentences: ["Das Haus ist gross."])
    assert_equal ["Das Haus ist gross."], word.example_sentences
  end

  test "#example_sentences ignores an empty sentence" do
    word = create(:noun, name: "Haus")
    assert_equal true, word.update(example_sentences: ["   "])
    assert_equal [], word.example_sentences
  end

  test "#example_sentences deletes a sentence" do
    word = create(:noun, name: "Haus")
    example_sentence = Faker::Lorem.sentence
    word.update!(example_sentences: [example_sentence])
    assert_equal [example_sentence], word.example_sentences

    assert_equal true, word.update(example_sentences: [])

    assert_equal [], word.example_sentences
  end

  test "#set_consonant_vowel detects vowels and consonants" do
    word = create(:noun, name: "Ähre")
    assert_equal "VKKV", word.consonant_vowel
  end

  test "#set_consonant_vowel ignores non alphabetic characters" do
    word = create(:noun, name: "Äh-r  9eß")
    assert_equal "VKKVK", word.consonant_vowel
  end

  test "#other_meanings without other meanings has no other meanings" do
    noun = create(:noun, name: "Ticken")
    assert_equal 0, noun.other_meanings.count
  end

  test "#other_meanings with other meanings has other meanings" do
    noun = create(:noun, name: "Ticken")
    create(:verb, name: "ticken")
    assert_equal 1, noun.other_meanings.count
  end

  test "#cologne_phonetics creates phonetics when creating a word" do
    word = create(:noun, name: "Adler", plural: "Häuser")
    assert_equal ["0257", "087"], word.cologne_phonetics
  end

  test "#cologne_phonetics updates phonetics when updating a word" do
    word = create(:noun, name: "Adler")
    assert_equal ["0257"], word.cologne_phonetics

    word.update!(name: "Haus")
    word.reload
    assert_equal ["08"], word.cologne_phonetics
  end

  test "#cologne_phonetics only stores unique phonetics" do
    word = create(:noun, name: "Adler", plural: "Adler")
    assert_equal ["0257"], word.cologne_phonetics
  end

  test "audio attachment is automatically generated when with_tts is set to true" do
    word = create(:noun, name: "Adler", with_tts: false)
    assert_equal false, word.audios.attached?

    assert_enqueued_with(job: TtsJob, args: [word]) do
      word.update!(with_tts: true)
    end
  end

  test "audio attachment is automatically regenerated when example sentences or name change" do
    word = create(:noun, name: "Adler", with_tts: true)

    assert_enqueued_with(job: TtsJob, args: [word]) do
      word.update!(name: "Geier")
    end

    assert_enqueued_with(job: TtsJob, args: [word]) do
      word.update!(example_sentences: ["Beispiel-Satz 1"])
    end

    assert_enqueued_with(job: TtsJob, args: [word]) do
      word.update!(example_sentences: ["Beispiel-Satz 1", "Beispiel-Satz 2"])
    end
  end

  test "audio attachment is not regenerated when neither example sentences nor name changes" do
    word = create(:noun, name: "Adler", with_tts: true, example_sentences: ["Beispiel-Satz 1"])

    assert_no_enqueued_jobs(only: TtsJob) do
      word.update!(plural: "Adlers")
    end
  end

  test "audio attachment is automatically removed when with_tts is set to false" do
    word = create(:noun, name: "Adler")
    word.audios.attach(fixture_file_upload("audio.mp3", "audio/mpeg"))
    word.save!

    assert_equal true, word.audios.attached?

    word.update!(with_tts: false)
    assert_equal false, word.audios.attached?
  end
end
