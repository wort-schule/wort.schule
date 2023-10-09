# frozen_string_literal: true

RSpec.describe Word do
  subject(:word) { build :word }

  describe "#syllables_count" do
    subject { word.syllables_count }

    context "with an empty string" do
      before { word.syllables = "" }

      it { is_expected.to eq 0 }
    end

    context "with whitespaces" do
      before { word.syllables = "   " }

      it { is_expected.to eq 0 }
    end

    context "with only one syllable" do
      before { word.syllables = "see" }

      it { is_expected.to eq 1 }
    end

    context "with multiple syllables" do
      before { word.syllables = "katz-en-baum" }

      it { is_expected.to eq 3 }
    end

    context "with multiple syllables and whitespaces" do
      before { word.syllables = " katz-en- baum" }

      it { is_expected.to eq 3 }
    end
  end

  describe "#opposites" do
    subject(:word) { create :noun, name: "Haus" }
    let(:synonym) { create :noun, name: "Gebäude" }

    it "adds a synonym" do
      word.synonyms << synonym
      word.reload

      expect(word.synonyms).to match [synonym]
    end

    context "with an existing synonym" do
      before do
        word.synonyms << synonym
      end

      it "does not add a duplicate" do
        word.synonyms << synonym
        word.reload

        expect(word.synonyms).to match [synonym]
      end
    end
  end

  describe "#example_sentences" do
    subject(:word) { create :noun, name: "Haus" }

    it "adds a sentence" do
      expect(word.update(
        example_sentences: ["Das Haus ist gross."]
      )).to be true

      expect(word.example_sentences).to match_array ["Das Haus ist gross."]
    end

    it "ignores an empty sentence" do
      expect(word.update(
        example_sentences: ["   "]
      )).to be true

      expect(word.example_sentences).to match_array []
    end

    context "with existing example sentence" do
      let!(:example_sentence) { Faker::Lorem.sentence }

      it "deletes a sentence" do
        word.update!(example_sentences: [example_sentence])
        expect(word.example_sentences).to match_array [example_sentence]

        expect(word.update(
          example_sentences: []
        )).to be true

        expect(word.example_sentences).to match_array []
      end
    end
  end

  describe "#filter_home" do
    it "filters words" do
      word = create :noun, name: "Ähre"
      expect(Noun.filter_home("ähre")).to include word
    end

    it "ignores whitespaces" do
      word1 = create :noun, name: "Ähre"
      word2 = create :noun, name: "American Football"
      expect(Noun.filter_home("ähre ")).to include word1
      expect(Noun.filter_home("american  football ")).to include word2
    end

    it "sorts results" do
      words = %w[Polizeiauto Polizei Polizeihund]
      objs = words.map { |name| create :noun, name: }

      expect(Noun.filter_home("polizei").map(&:id)).to eq [objs[1].id, objs[0].id, objs[2].id]
      expect(Noun.filter_home("polizei").map(&:name)).to eq %w[
        Polizei
        Polizeiauto
        Polizeihund
      ]
    end

    it "sorts results for hits not in base form" do
      words = [
        create(:noun, name: "Kindergarten"),
        create(:noun, name: "Kindergärtner"),
        create(:noun, name: "Kind", plural: "Kinder")
      ]

      expect(Noun.filter_home("kinder").map(&:id)).to eq [words[2].id, words[0].id, words[1].id]
      expect(Noun.filter_home("kinder").map(&:name)).to eq %w[
        Kind
        Kindergarten
        Kindergärtner
      ]
    end
  end

  describe "#filter_letters" do
    it "matches umlauts" do
      word = create :noun, name: "Ähre"
      expect(Noun.filter_letters("ä")).to include word
      expect(Word.filter_letters("ä")).to include word
    end

    it "requires all letters to be present" do
      word1 = create :noun, name: "Abc"
      create :noun, name: "A"
      expect(Noun.filter_letters("ac")).to match [word1]
      expect(Word.filter_letters("ac")).to match [word1]
    end
  end

  describe "#filter_source" do
    it "finds words with a specific source" do
      source = create :source
      word = create :noun, sources: [source]
      create :noun

      expect(Noun.filter_source(source.id)).to match [word]
      expect(Word.filter_source(source.id)).to match [word]
    end
  end

  describe "#filter_topic" do
    it "finds words with a specific topic" do
      topic = create :topic
      word = create :noun, topics: [topic]
      create :noun

      expect(Word.filter_topic(topic.id)).to match [word]
      expect(Noun.filter_topic(topic.id)).to match [word]
    end
  end

  describe "#filter_hierarchy" do
    it "finds words with a specific hierarchy" do
      hierarchy = create :hierarchy
      word = create(:noun, hierarchy:)
      create :noun

      expect(Noun.filter_hierarchy(hierarchy.id)).to match [word]
      expect(Word.filter_hierarchy(hierarchy.id)).to match [word]
    end
  end

  describe "#filter_phenomenons" do
    it "finds words with a specific phenomenon" do
      phenomenon = create :phenomenon
      word = create(:noun, phenomenons: [phenomenon])
      create :noun

      expect(Noun.filter_phenomenons(OpenStruct.new(
        conjunction: "and", phenomenons: [phenomenon.id]
      ))).to match [word]
      expect(Word.filter_phenomenons(OpenStruct.new(
        conjunction: "and", phenomenons: [phenomenon.id]
      ))).to match [word]
    end

    it "finds words with multiple ORed phenomenons" do
      phenomenon1 = create :phenomenon
      phenomenon2 = create :phenomenon
      word1 = create(:noun, phenomenons: [phenomenon1, phenomenon2])
      word2 = create :noun, phenomenons: [phenomenon1]

      expect(Noun.filter_phenomenons(OpenStruct.new(
        conjunction: "or", phenomenons: [phenomenon1.id, phenomenon2.id]
      ))).to match_array [word1, word2]
      expect(Word.filter_phenomenons(OpenStruct.new(
        conjunction: "or", phenomenons: [phenomenon1.id, phenomenon2.id]
      ))).to match_array [word1, word2]
    end

    it "finds words with multiple ANDed phenomenons" do
      phenomenon1 = create :phenomenon
      phenomenon2 = create :phenomenon
      word = create(:noun, phenomenons: [phenomenon1, phenomenon2])
      create :noun, phenomenons: [phenomenon1]

      expect(Noun.filter_phenomenons(OpenStruct.new(
        conjunction: "and", phenomenons: [phenomenon1.id, phenomenon2.id]
      ))).to match_array [word]
      expect(Word.filter_phenomenons(OpenStruct.new(
        conjunction: "and", phenomenons: [phenomenon1.id, phenomenon2.id]
      ))).to match_array [word]
    end
  end

  describe "#filter_strategies" do
    it "finds words with a specific strategy" do
      strategy = create :strategy
      word = create(:noun, strategies: [strategy])
      create :noun

      expect(Noun.filter_strategies(OpenStruct.new(
        conjunction: "and", strategies: [strategy.id]
      ))).to match_array [word]
      expect(Word.filter_strategies(OpenStruct.new(
        conjunction: "and", strategies: [strategy.id]
      ))).to match_array [word]
    end

    it "finds words with multiple ORed strategies" do
      strategy1 = create :strategy
      strategy2 = create :strategy
      word1 = create(:noun, strategies: [strategy1, strategy2])
      word2 = create :noun, strategies: [strategy1]

      expect(Noun.filter_strategies(OpenStruct.new(
        conjunction: "or", strategies: [strategy1.id, strategy2.id]
      ))).to match_array [word1, word2]
      expect(Word.filter_strategies(OpenStruct.new(
        conjunction: "or", strategies: [strategy1.id, strategy2.id]
      ))).to match_array [word1, word2]
    end

    it "finds words with multiple ANDed strategies" do
      strategy1 = create :strategy
      strategy2 = create :strategy
      word = create(:noun, strategies: [strategy1, strategy2])
      create :noun, strategies: [strategy1]

      expect(Noun.filter_strategies(OpenStruct.new(
        conjunction: "and", strategies: [strategy1.id, strategy2.id]
      ))).to match [word]
      expect(Word.filter_strategies(OpenStruct.new(
        conjunction: "and", strategies: [strategy1.id, strategy2.id]
      ))).to match [word]
    end
  end

  describe "#filter_keywords" do
    it "finds words with a specific keyword" do
      keyword = create :noun
      word = create :noun
      word.update!(keyword_ids: [keyword.id])
      create :noun

      expect(Noun.filter_keywords(OpenStruct.new(
        conjunction: "and", keywords: [keyword.id]
      ))).to match [word]
      expect(Word.filter_keywords(OpenStruct.new(
        conjunction: "and", keywords: [keyword.id]
      ))).to match [word]
    end

    it "finds words with multiple ORed keywords" do
      keyword1 = create :noun
      keyword2 = create :noun
      word1 = create :noun
      word1.update!(keyword_ids: [keyword1.id, keyword2.id])
      word2 = create :noun, keywords: [keyword1]
      word2.update!(keyword_ids: [keyword1.id])

      expect(Noun.filter_keywords(OpenStruct.new(
        conjunction: "or", keywords: [keyword1.id, keyword2.id]
      ))).to match_array [word1, word2]
      expect(Word.filter_keywords(OpenStruct.new(
        conjunction: "or", keywords: [keyword1.id, keyword2.id]
      ))).to match_array [word1, word2]
    end

    it "finds words with multiple ANDed keywords" do
      keyword1 = create :noun
      keyword2 = create :noun
      word = create :noun
      word.update!(keyword_ids: [keyword1.id, keyword2.id])
      other_word = create :noun, keywords: [keyword1]
      other_word.update!(keyword_ids: [keyword1.id])

      expect(Noun.filter_keywords(OpenStruct.new(
        conjunction: "and", keywords: [keyword1.id, keyword2.id]
      ))).to match [word]
      expect(Word.filter_keywords(OpenStruct.new(
        conjunction: "and", keywords: [keyword1.id, keyword2.id]
      ))).to match [word]
    end
  end

  describe "#filter_consonant_vowel" do
    it "finds words with a specific consonant vowel" do
      word = create :noun, name: "Baum"
      create :noun

      expect(Noun.filter_consonant_vowel("KVVK")).to match [word]
      expect(Word.filter_consonant_vowel("KVVK")).to match [word]
    end
  end

  describe "#filter_foreign" do
    it "finds words which are foreign" do
      word = create :noun, foreign: true
      not_foreign = create :noun, foreign: false

      expect(Noun.filter_foreign("yes")).to match [word]
      expect(Word.filter_foreign("yes")).to match [word]
      expect(Noun.filter_foreign("no")).to match [not_foreign]
      expect(Word.filter_foreign("no")).to match [not_foreign]
      expect(Noun.filter_foreign("")).to match_array [word, not_foreign]
      expect(Word.filter_foreign("")).to match_array [word, not_foreign]
    end
  end

  describe "#filter_prototype" do
    it "finds words which are prototypes" do
      word = create :noun, prototype: true
      create :noun, prototype: false

      expect(Noun.filter_prototype("yes")).to match [word]
      expect(Word.filter_prototype("yes")).to match [word]
    end
  end

  describe "#filter_compound" do
    it "finds words which are compound" do
      word = create :noun, compound: true
      create :noun, compound: false

      expect(Noun.filter_compound("yes")).to match [word]
      expect(Word.filter_compound("yes")).to match [word]
    end
  end

  describe "#filter_example_sentences" do
    it "finds words which have example sentences" do
      word = create :noun, example_sentences: [Faker::Lorem.sentence]
      create :noun

      expect(Noun.filter_example_sentences("yes")).to match [word]
      expect(Word.filter_example_sentences("yes")).to match [word]
    end
  end

  describe "#filter_singularetantum" do
    it "finds words which are singularetantum" do
      word = create :noun, singularetantum: true
      create :noun, singularetantum: false

      expect(Noun.filter_singularetantum("yes")).to match [word]
      expect(Word.filter_singularetantum("yes")).to match [word]
    end
  end

  describe "#filter_pluraletantum" do
    it "finds words which are pluraletantum" do
      word = create :noun, pluraletantum: true
      create :noun, pluraletantum: false

      expect(Noun.filter_pluraletantum("yes")).to match [word]
      expect(Word.filter_pluraletantum("yes")).to match [word]
    end
  end

  describe "#filter_smart" do
    it "finds exact matches as well as phonetic ones" do
      word1 = create :noun, name: "Fahre"
      word2 = create :noun, name: "Havarie"

      expect(Noun.filter_smart("var")).to match_array [word1, word2]
    end

    it "finds plural form of noun" do
      word = create :noun, name: "Kind", plural: "Kinder"

      expect(Noun.filter_smart("kinder")).to match [word]
    end

    it "finds word types" do
      noun = create :noun
      verb = create :verb
      adjective = create :adjective

      expect(Word.filter_type("Noun")).to match [noun]
      expect(Word.filter_type("Verb")).to match [verb]
      expect(Word.filter_type("Adjective")).to match [adjective]
      expect(Word.filter_type("")).to match_array [noun, verb, adjective]
    end
  end

  describe "#filter_example_sentences" do
    it "finds words which have example sentences" do
      word = create :noun, example_sentences: [Faker::Lorem.sentence]
      create :noun

      expect(Noun.filter_example_sentences("yes")).to match [word]
      expect(Word.filter_example_sentences("yes")).to match [word]
    end
  end

  describe "#set_consonant_vowel" do
    it "detects vowels and consonants" do
      word = create :noun, name: "Ähre"

      expect(word.consonant_vowel).to eq "VKKV"
    end

    it "ignores non alphabetic characters" do
      word = create :noun, name: "Äh-r  9eß"

      expect(word.consonant_vowel).to eq "VKKVK"
    end
  end

  describe "#other_meanings" do
    context "without other meanings" do
      let!(:noun) { create :noun, name: "Ticken" }

      it "has no other meanings" do
        expect(noun.other_meanings.count).to eq 0
      end
    end

    context "with other meanings" do
      let!(:noun) { create :noun, name: "Ticken" }
      let!(:verb) { create :verb, name: "ticken" }

      it "has other meanings" do
        expect(noun.other_meanings.count).to eq 1
      end
    end
  end

  describe "#cologne_phonetics" do
    it "creates phonetics when creating a word" do
      word = create :noun, name: "Adler", plural: "Häuser"
      expect(word.cologne_phonetics).to eq ["0257", "087"]
    end

    it "updates phonetics when updating a word" do
      word = create :noun, name: "Adler"
      expect(word.cologne_phonetics).to eq ["0257"]

      word.update!(name: "Haus")
      word.reload
      expect(word.cologne_phonetics).to eq ["08"]
    end

    it "only stores unique phonetics" do
      word = create :noun, name: "Adler", plural: "Adler"
      expect(word.cologne_phonetics).to eq ["0257"]
    end
  end

  describe "audio attachment" do
    it "is generated when a word is created" do
      expect {
        create(:noun, name: "Adler", with_tts: true)
      }.to have_enqueued_job(TtsJob).with(Noun.last)
    end

    it "is automatically generated when with_tts is set to true" do
      word = create(:noun, name: "Adler", with_tts: false)
      expect(word.audios.attached?).to be false

      expect {
        word.update!(with_tts: true)
      }.to have_enqueued_job(TtsJob).with(word)
    end

    it "is automatically regenerated when the example sentences or the name of the word changes" do
      word = create(:noun, name: "Adler", with_tts: true)

      expect {
        word.update!(name: "Geier")
      }.to have_enqueued_job(TtsJob).with(word)

      expect {
        word.update!(example_sentences: ["Beispiel-Satz 1"])
      }.to have_enqueued_job(TtsJob).with(word)

      expect {
        word.update!(example_sentences: ["Beispiel-Satz 1", "Beispiel-Satz 2"])
      }.to have_enqueued_job(TtsJob).with(word)
    end

    it "is not automatically regenerated when neither the example sentences nor the name of the word changes" do
      word = create(:noun, name: "Adler", with_tts: true, example_sentences: ["Beispiel-Satz 1"])

      expect {
        word.update!(plural: "Adlers")
      }.not_to have_enqueued_job(TtsJob).with(word)
    end

    it "is automatically removed when with_tts is set to false" do
      word = create(:noun, name: "Adler")
      word.audios.attach(fixture_file_upload("audio.mp3", "audio/mpeg"))
      word.save!

      expect(word.audios.attached?).to be true

      word.update!(with_tts: false)
      expect(word.audios.attached?).to be false
    end
  end
end
