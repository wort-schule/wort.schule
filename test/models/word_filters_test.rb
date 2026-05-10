# frozen_string_literal: true

require "test_helper"

class WordFiltersTest < ActiveSupport::TestCase
  test "#filter_home filters words" do
    word = create(:noun, name: "Ähre")
    assert_includes Noun.filter_home("ähre"), word
  end

  test "#filter_home ignores whitespaces" do
    word1 = create(:noun, name: "Ähre")
    word2 = create(:noun, name: "American Football")
    assert_includes Noun.filter_home("ähre "), word1
    assert_includes Noun.filter_home("american  football "), word2
  end

  test "#filter_home sorts results" do
    words = %w[Polizeiauto Polizei Polizeihund]
    objs = words.map { |name| create(:noun, name: name) }

    assert_equal [objs[1].id, objs[0].id, objs[2].id], Noun.filter_home("polizei").map(&:id)
    assert_equal %w[Polizei Polizeiauto Polizeihund], Noun.filter_home("polizei").map(&:name)
  end

  test "#filter_home sorts results for hits not in base form" do
    words = [
      create(:noun, name: "Kindergarten"),
      create(:noun, name: "Kindergärtner"),
      create(:noun, name: "Kind", plural: "Kinder")
    ]

    assert_equal [words[2].id, words[0].id, words[1].id], Noun.filter_home("kinder").map(&:id)
    assert_equal %w[Kind Kindergarten Kindergärtner], Noun.filter_home("kinder").map(&:name)
  end

  test "#filter_letters matches umlauts" do
    word = create(:noun, name: "Ähre")
    assert_includes Noun.filter_letters("ä"), word
    assert_includes Word.filter_letters("ä"), word
  end

  test "#filter_letters requires all letters to be present" do
    word1 = create(:noun, name: "Abc")
    create(:noun, name: "A")
    assert_equal [word1], Noun.filter_letters("ac").to_a
    assert_equal [word1], Word.filter_letters("ac").to_a
  end

  test "#filter_source finds words with a specific source" do
    source = create(:source)
    word = create(:noun, sources: [source])
    create(:noun)

    assert_equal [word], Noun.filter_source(source.id).to_a
    assert_equal [word], Word.filter_source(source.id).to_a
  end

  test "#filter_topic finds words with a specific topic" do
    topic = create(:topic)
    word = create(:noun, topics: [topic])
    create(:noun)

    assert_equal [word], Word.filter_topic(topic.id).to_a
    assert_equal [word], Noun.filter_topic(topic.id).to_a
  end

  test "#filter_hierarchy finds words with a specific hierarchy" do
    hierarchy = create(:hierarchy)
    word = create(:noun, hierarchy: hierarchy)
    create(:noun)

    assert_equal [word], Noun.filter_hierarchy(hierarchy.id).to_a
    assert_equal [word], Word.filter_hierarchy(hierarchy.id).to_a
  end

  test "#filter_phenomenons finds words with a specific phenomenon" do
    phenomenon = create(:phenomenon)
    word = create(:noun, phenomenons: [phenomenon])
    create(:noun)

    assert_equal [word], Noun.filter_phenomenons(OpenStruct.new(
      conjunction: "and", phenomenons: [phenomenon.id]
    )).to_a
    assert_equal [word], Word.filter_phenomenons(OpenStruct.new(
      conjunction: "and", phenomenons: [phenomenon.id]
    )).to_a
  end

  test "#filter_phenomenons finds words with multiple ORed phenomenons" do
    phenomenon1 = create(:phenomenon)
    phenomenon2 = create(:phenomenon)
    word1 = create(:noun, phenomenons: [phenomenon1, phenomenon2])
    word2 = create(:noun, phenomenons: [phenomenon1])

    assert_equal [word1, word2].sort_by(&:id), Noun.filter_phenomenons(OpenStruct.new(
      conjunction: "or", phenomenons: [phenomenon1.id, phenomenon2.id]
    )).sort_by(&:id)
    assert_equal [word1, word2].sort_by(&:id), Word.filter_phenomenons(OpenStruct.new(
      conjunction: "or", phenomenons: [phenomenon1.id, phenomenon2.id]
    )).sort_by(&:id)
  end

  test "#filter_phenomenons finds words with multiple ANDed phenomenons" do
    phenomenon1 = create(:phenomenon)
    phenomenon2 = create(:phenomenon)
    word = create(:noun, phenomenons: [phenomenon1, phenomenon2])
    create(:noun, phenomenons: [phenomenon1])

    assert_equal [word], Noun.filter_phenomenons(OpenStruct.new(
      conjunction: "and", phenomenons: [phenomenon1.id, phenomenon2.id]
    )).to_a
    assert_equal [word], Word.filter_phenomenons(OpenStruct.new(
      conjunction: "and", phenomenons: [phenomenon1.id, phenomenon2.id]
    )).to_a
  end

  test "#filter_strategies finds words with a specific strategy" do
    strategy = create(:strategy)
    word = create(:noun, strategies: [strategy])
    create(:noun)

    assert_equal [word], Noun.filter_strategies(OpenStruct.new(
      conjunction: "and", strategies: [strategy.id]
    )).to_a
    assert_equal [word], Word.filter_strategies(OpenStruct.new(
      conjunction: "and", strategies: [strategy.id]
    )).to_a
  end

  test "#filter_strategies finds words with multiple ORed strategies" do
    strategy1 = create(:strategy)
    strategy2 = create(:strategy)
    word1 = create(:noun, strategies: [strategy1, strategy2])
    word2 = create(:noun, strategies: [strategy1])

    assert_equal [word1, word2].sort, Noun.filter_strategies(OpenStruct.new(
      conjunction: "or", strategies: [strategy1.id, strategy2.id]
    )).sort
    assert_equal [word1, word2].sort, Word.filter_strategies(OpenStruct.new(
      conjunction: "or", strategies: [strategy1.id, strategy2.id]
    )).sort
  end

  test "#filter_strategies finds words with multiple ANDed strategies" do
    strategy1 = create(:strategy)
    strategy2 = create(:strategy)
    word = create(:noun, strategies: [strategy1, strategy2])
    create(:noun, strategies: [strategy1])

    assert_equal [word], Noun.filter_strategies(OpenStruct.new(
      conjunction: "and", strategies: [strategy1.id, strategy2.id]
    )).to_a
    assert_equal [word], Word.filter_strategies(OpenStruct.new(
      conjunction: "and", strategies: [strategy1.id, strategy2.id]
    )).to_a
  end

  test "#filter_keywords finds words with a specific keyword" do
    keyword = create(:noun)
    word = create(:noun)
    word.update!(keyword_ids: [keyword.id])
    create(:noun)

    assert_equal [word], Noun.filter_keywords(OpenStruct.new(
      conjunction: "and", keywords: [keyword.id]
    )).to_a
    assert_equal [word], Word.filter_keywords(OpenStruct.new(
      conjunction: "and", keywords: [keyword.id]
    )).to_a
  end

  test "#filter_keywords finds words with multiple ORed keywords" do
    keyword1 = create(:noun)
    keyword2 = create(:noun)
    word1 = create(:noun)
    word1.update!(keyword_ids: [keyword1.id, keyword2.id])
    word2 = create(:noun, keywords: [keyword1])
    word2.update!(keyword_ids: [keyword1.id])

    assert_equal [word1, word2].sort, Noun.filter_keywords(OpenStruct.new(
      conjunction: "or", keywords: [keyword1.id, keyword2.id]
    )).sort
    assert_equal [word1, word2].sort, Word.filter_keywords(OpenStruct.new(
      conjunction: "or", keywords: [keyword1.id, keyword2.id]
    )).sort
  end

  test "#filter_keywords finds words with multiple ANDed keywords" do
    keyword1 = create(:noun)
    keyword2 = create(:noun)
    word = create(:noun)
    word.update!(keyword_ids: [keyword1.id, keyword2.id])
    other_word = create(:noun, keywords: [keyword1])
    other_word.update!(keyword_ids: [keyword1.id])

    assert_equal [word], Noun.filter_keywords(OpenStruct.new(
      conjunction: "and", keywords: [keyword1.id, keyword2.id]
    )).to_a
    assert_equal [word], Word.filter_keywords(OpenStruct.new(
      conjunction: "and", keywords: [keyword1.id, keyword2.id]
    )).to_a
  end

  test "#filter_consonant_vowel finds words with a specific consonant vowel" do
    word = create(:noun, name: "Baum")
    create(:noun)

    assert_equal [word], Noun.filter_consonant_vowel("KVVK").to_a
    assert_equal [word], Word.filter_consonant_vowel("KVVK").to_a
  end

  test "#filter_foreign finds words which are foreign" do
    word = create(:noun, foreign: true)
    not_foreign = create(:noun, foreign: false)

    assert_equal [word], Noun.filter_foreign("yes").to_a
    assert_equal [word], Word.filter_foreign("yes").to_a
    assert_equal [not_foreign], Noun.filter_foreign("no").to_a
    assert_equal [not_foreign], Word.filter_foreign("no").to_a
    assert_equal [word, not_foreign].sort, Noun.filter_foreign("").sort
    assert_equal [word, not_foreign].sort, Word.filter_foreign("").sort
  end

  test "#filter_prototype finds words which are prototypes" do
    word = create(:noun, prototype: true)
    create(:noun, prototype: false)

    assert_equal [word], Noun.filter_prototype("yes").to_a
    assert_equal [word], Word.filter_prototype("yes").to_a
  end

  test "#filter_compound finds words which are compound" do
    word = create(:noun, compound: true)
    create(:noun, compound: false)

    assert_equal [word], Noun.filter_compound("yes").to_a
    assert_equal [word], Word.filter_compound("yes").to_a
  end

  test "#filter_example_sentences finds words which have example sentences" do
    word = create(:noun, example_sentences: [Faker::Lorem.sentence])
    create(:noun)

    assert_equal [word], Noun.filter_example_sentences("yes").to_a
    assert_equal [word], Word.filter_example_sentences("yes").to_a
  end

  test "#filter_singularetantum finds words which are singularetantum" do
    word = create(:noun, singularetantum: true)
    create(:noun, singularetantum: false)

    assert_equal [word], Noun.filter_singularetantum("yes").to_a
    assert_equal [word], Word.filter_singularetantum("yes").to_a
  end

  test "#filter_pluraletantum finds words which are pluraletantum" do
    word = create(:noun, pluraletantum: true)
    create(:noun, pluraletantum: false)

    assert_equal [word], Noun.filter_pluraletantum("yes").to_a
    assert_equal [word], Word.filter_pluraletantum("yes").to_a
  end

  test "#filter_smart finds exact matches as well as phonetic ones" do
    word1 = create(:noun, name: "Fahre")
    word2 = create(:noun, name: "Havarie")

    assert_equal [word1, word2].sort, Noun.filter_smart("var").sort
  end

  test "#filter_smart finds plural form of noun" do
    word = create(:noun, name: "Kind", plural: "Kinder")

    assert_equal [word], Noun.filter_smart("kinder").to_a
  end

  test "#filter_smart finds word types" do
    noun = create(:noun)
    verb = create(:verb)
    adjective = create(:adjective)

    assert_equal [noun], Word.filter_type("Noun").to_a
    assert_equal [verb], Word.filter_type("Verb").to_a
    assert_equal [adjective], Word.filter_type("Adjective").to_a
    assert_equal [noun, verb, adjective].sort_by(&:id), Word.filter_type("").sort_by(&:id)
  end

  test "#filter_letter_count finds words correctly" do
    mouse = create(:noun, name: "Maus")
    red_card = create(:noun, name: " Rote Karte")

    assert_equal [mouse], Noun.filter_letter_count("4").to_a
    assert_equal [red_card], Noun.filter_letter_count("9").to_a
  end

  test "#filter_syllables_count finds words correctly" do
    create(:noun, syllables: "")
    one = create(:noun, syllables: "hoch")
    two = create(:noun, syllables: "höl-zern")
    three = create(:noun, syllables: "hilfs-be-reit")
    four = create(:noun, syllables: "hin-ter-häl-tig")

    assert_equal [one], Noun.filter_syllables_count("1").to_a
    assert_equal [two], Noun.filter_syllables_count("2").to_a
    assert_equal [three], Noun.filter_syllables_count("3").to_a
    assert_equal [four], Noun.filter_syllables_count("4").to_a
  end
end
