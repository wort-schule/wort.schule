json.cache! ["v1", function_word], expires_in: 15.minutes do
  json.extract! function_word,
    :id,
    :name,
    :foreign,
    :meaning,
    :meaning_long,
    :prototype,
    :syllables,
    :written_syllables

  json.word_type function_word.class.model_name.human
  json.image_url function_word.image.attached? ? Rails.application.routes.url_helpers.rails_storage_proxy_url(function_word.image, host: Rails.application.routes.default_url_options[:host], protocol: Rails.application.routes.default_url_options[:protocol]) : nil
  json.compound_entities function_word.compound_entities.map(&:part).map(&:name)
  json.example_sentences function_word.example_sentences
  json.hierarchy do
    function_word.hierarchy&.tap do |hierarchy|
      json.id hierarchy.id
      json.id hierarchy.name
    end || json.nil!
  end
  json.keywords function_word.keywords.map(&:name)
  json.opposites function_word.opposites.map(&:name)
  json.other_meanings function_word.other_meanings.map(&:name)
  json.phenomenons function_word.phenomenons.map(&:name)
  json.postfix do
    function_word.postfix&.tap do |postfix|
      json.id postfix.id
      json.name postfix.name
    end
  end
  json.prefix do
    function_word.prefix&.tap do |prefix|
      json.id prefix.id
      json.name prefix.name
    end
  end
  json.rimes function_word.rimes.map(&:name)
  json.strategies do
    json.array! function_word.strategies, :id, :name
  end
  json.synonyms function_word.synonyms.map(&:name)
  json.topics function_word.topics.map(&:name)
  json.function_type function_word.function_type_text
end
