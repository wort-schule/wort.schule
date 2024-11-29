json.cache! ["v1", verb], expires_in: 15.minutes do
  json.extract! verb,
    :id,
    :name,
    :compound,
    :foreign,
    :meaning_long,
    :meaning,
    :prototype,
    :syllables,
    :written_syllables,
    :imperative_singular,
    :imperative_plural,
    :participle,
    :past_participle,
    :perfect_haben,
    :perfect_sein,
    :present_singular_1,
    :present_singular_2,
    :present_singular_3,
    :present_plural_1,
    :present_plural_2,
    :present_plural_3,
    :past_singular_1,
    :past_singular_2,
    :past_singular_3,
    :past_plural_1,
    :past_plural_2,
    :past_plural_3,
    :subjectless,
    :strong

  json.word_type verb.class.model_name.human
  json.compound_entities verb.compound_entities.map(&:part).map(&:name)
  json.example_sentences verb.example_sentences
  json.hierarchy do
    verb.hierarchy&.tap do |hierarchy|
      json.id hierarchy.id
      json.id hierarchy.name
    end || json.nil!
  end
  json.keywords verb.keywords.map(&:name)
  json.opposites verb.opposites.map(&:name)
  json.other_meanings verb.other_meanings.map(&:name)
  json.phenomenons verb.phenomenons.map(&:name)
  json.postfix do
    verb.postfix&.tap do |postfix|
      json.id postfix.id
      json.name postfix.name
    end
  end
  json.prefix do
    verb.prefix&.tap do |prefix|
      json.id prefix.id
      json.name prefix.name
    end
  end
  json.rimes verb.rimes.map(&:name)
  json.strategies do
    json.array! verb.strategies, :id, :name
  end
  json.synonyms verb.synonyms.map(&:name)
  json.topics verb.topics.map(&:name)
end
