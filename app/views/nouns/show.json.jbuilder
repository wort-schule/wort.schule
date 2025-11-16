json.cache! ["v1", noun], expires_in: 15.minutes do
  json.extract! noun,
    :id,
    :name,
    :meaning,
    :meaning_long,
    :prototype,
    :foreign,
    :compound,
    :syllables,
    :written_syllables,
    :plural,
    :singularetantum,
    :pluraletantum

  json.word_type noun.class.model_name.human
  json.image_url noun.image.attached? ? noun.image.url : nil
  json.compound_entities noun.compound_entities.map(&:part).map(&:name)
  json.example_sentences noun.example_sentences
  json.hierarchy do
    noun.hierarchy&.tap do |hierarchy|
      json.id hierarchy.id
      json.id hierarchy.name
    end || json.nil!
  end
  json.keywords noun.keywords.map(&:name)
  json.opposites noun.opposites.map(&:name)
  json.other_meanings noun.other_meanings.map(&:name)
  json.phenomenons noun.phenomenons.map(&:name)
  json.postfix do
    noun.postfix&.tap do |postfix|
      json.id postfix.id
      json.name postfix.name
    end
  end
  json.prefix do
    noun.prefix&.tap do |prefix|
      json.id prefix.id
      json.name prefix.name
    end
  end
  json.rimes noun.rimes.map(&:name)
  json.strategies do
    json.array! noun.strategies, :id, :name
  end
  json.synonyms noun.synonyms.map(&:name)
  json.topics noun.topics.map(&:name)
  json.genus_neuter noun.genus_neuter&.name
  json.genus_masculine noun.genus_masculine&.name
  json.genus_feminine noun.genus_feminine&.name
  json.case_1_singular do
    json.article noun.article_definite(case_number: 1, singular: true)
    json.name noun.case_1_singular
  end
  json.case_2_singular do
    json.article noun.article_definite(case_number: 2, singular: true)
    json.name noun.case_2_singular
  end
  json.case_3_singular do
    json.article noun.article_definite(case_number: 3, singular: true)
    json.name noun.case_3_singular
  end
  json.case_4_singular do
    json.article noun.article_definite(case_number: 4, singular: true)
    json.name noun.case_4_singular
  end
  json.case_1_plural do
    json.article noun.article_definite(case_number: 1, singular: false)
    json.name noun.case_1_plural
  end
  json.case_2_plural do
    json.article noun.article_definite(case_number: 2, singular: false)
    json.name noun.case_2_plural
  end
  json.case_3_plural do
    json.article noun.article_definite(case_number: 3, singular: false)
    json.name noun.case_3_plural
  end
  json.case_4_plural do
    json.article noun.article_definite(case_number: 4, singular: false)
    json.name noun.case_4_plural
  end
end
