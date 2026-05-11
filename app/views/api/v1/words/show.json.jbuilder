json.cache! ["api-v1", @word], expires_in: 15.minutes do
  # Basis
  json.id @word.id
  json.name @word.name
  json.slug @word.slug
  json.type @word.type
  json.word_type @word.class.model_name.human

  # Bedeutung
  json.meaning @word.meaning
  json.meaning_long @word.meaning_long

  # Silben
  json.syllables @word.syllables
  json.written_syllables @word.written_syllables

  # Eigenschaften
  json.prototype @word.prototype
  json.foreign @word.foreign
  json.compound @word.compound

  # Bild
  if @word.image.attached?
    json.image do
      json.url rails_storage_proxy_url(@word.image)
      json.thumb_url rails_storage_proxy_url(@word.image.variant(:thumb))
      json.alt_text @word.image_alt_text
    end
  else
    json.image nil
  end

  # Beispielsätze
  json.example_sentences @word.example_sentences

  # Verwandte Wörter
  json.keywords @word.keywords.map(&:name)
  json.synonyms @word.synonyms.map(&:name)
  json.opposites @word.opposites.map(&:name)
  json.rimes @word.rimes.map(&:name)
  json.compound_entities @word.compound_entities.map(&:part).map(&:name)

  # Kategorien
  json.topics @word.topics.map(&:name)
  json.phenomenons @word.phenomenons.map(&:name)
  json.strategies do
    json.array! @word.strategies, :id, :name
  end

  # Hierarchie
  json.hierarchy do
    if @word.hierarchy
      json.id @word.hierarchy.id
      json.name @word.hierarchy.name
    else
      json.nil!
    end
  end

  # Vor-/Nachsilbe
  json.prefix do
    if @word.prefix
      json.id @word.prefix.id
      json.name @word.prefix.name
    else
      json.nil!
    end
  end
  json.postfix do
    if @word.postfix
      json.id @word.postfix.id
      json.name @word.postfix.name
    else
      json.nil!
    end
  end

  # Typ-spezifische Felder
  case @word
  when Noun
    json.noun do
      json.plural @word.plural
      json.genus @word.genus&.name
      json.singularetantum @word.singularetantum
      json.pluraletantum @word.pluraletantum
      json.genus_masculine @word.genus_masculine&.name
      json.genus_feminine @word.genus_feminine&.name
      json.genus_neuter @word.genus_neuter&.name
      json.cases do
        (1..4).each do |case_num|
          json.set! "case_#{case_num}" do
            json.singular do
              json.article @word.article_definite(case_number: case_num, singular: true)
              json.form @word.public_send(:"case_#{case_num}_singular")
            end
            json.plural do
              json.article @word.article_definite(case_number: case_num, singular: false)
              json.form @word.public_send(:"case_#{case_num}_plural")
            end
          end
        end
      end
    end
  when Verb
    json.verb do
      json.subjectless @word.subjectless
      json.strong @word.strong
      json.imperative_singular @word.imperative_singular
      json.imperative_plural @word.imperative_plural
      json.participle @word.participle
      json.past_participle @word.past_participle
      json.perfect_haben @word.perfect_haben
      json.perfect_sein @word.perfect_sein
      json.present do
        json.singular_1 @word.present_singular_1
        json.singular_2 @word.present_singular_2
        json.singular_3 @word.present_singular_3
        json.plural_1 @word.present_plural_1
        json.plural_2 @word.present_plural_2
        json.plural_3 @word.present_plural_3
      end
      json.past do
        json.singular_1 @word.past_singular_1
        json.singular_2 @word.past_singular_2
        json.singular_3 @word.past_singular_3
        json.plural_1 @word.past_plural_1
        json.plural_2 @word.past_plural_2
        json.plural_3 @word.past_plural_3
      end
    end
  when Adjective
    json.adjective do
      json.comparative @word.comparative
      json.superlative @word.superlative
      json.absolute @word.absolute
      json.irregular_comparison @word.irregular_comparison
      json.irregular_declination @word.irregular_declination
    end
  when FunctionWord
    json.function_word do
      json.function_type @word.function_type
    end
  end
end
