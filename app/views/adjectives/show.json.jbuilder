json.cache! ["v1", adjective], expires_in: 15.minutes do
  json.extract! adjective,
    :id,
    :name,
    :foreign,
    :meaning,
    :meaning_long,
    :prototype,
    :syllables,
    :written_syllables,
    :comparative,
    :superlative,
    :absolute,
    :irregular_comparison,
    :irregular_declination

  json.word_type adjective.class.model_name.human
  json.compound_entities adjective.compound_entities.map(&:part).map(&:name)
  json.example_sentences adjective.example_sentences
  json.hierarchy do
    adjective.hierarchy&.tap do |hierarchy|
      json.id hierarchy.id
      json.id hierarchy.name
    end || json.nil!
  end
  json.keywords adjective.keywords.map(&:name)
  json.opposites adjective.opposites.map(&:name)
  json.other_meanings adjective.other_meanings.map(&:name)
  json.phenomenons adjective.phenomenons.map(&:name)
  json.postfix do
    adjective.postfix&.tap do |postfix|
      json.id postfix.id
      json.name postfix.name
    end
  end
  json.prefix do
    adjective.prefix&.tap do |prefix|
      json.id prefix.id
      json.name prefix.name
    end
  end
  json.rimes adjective.rimes.map(&:name)
  json.strategies do
    json.array! adjective.strategies, :id, :name
  end
  json.synonyms adjective.synonyms.map(&:name)
  json.topics adjective.topics.map(&:name)
end
