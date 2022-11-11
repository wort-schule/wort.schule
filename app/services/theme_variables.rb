# frozen_string_literal: true

class ThemeVariables
  extend WordHelper

  def self.noun_keys
    (noun_variables(Noun.new, "").keys - %i[labels]).sort
  end

  def self.verb_keys
    (verb_variables(Verb.new, "").keys - %i[labels]).sort
  end

  def self.adjective_keys
    (adjective_variables(Adjective.new, "").keys - %i[labels]).sort
  end

  def self.noun_variables(word, word_image_url)
    {
      word_type: word.class.model_name.human,
      singular: word.name,
      plural: word.plural,
      case_1_singular: word.case_1_singular,
      case_1_singular_article: word.article_definite(case_number: 1, singular: true),
      case_2_singular: word.case_2_singular,
      case_2_singular_article: word.article_definite(case_number: 2, singular: true),
      case_3_singular: word.case_3_singular,
      case_3_singular_article: word.article_definite(case_number: 3, singular: true),
      case_4_singular: word.case_4_singular,
      case_4_singular_article: word.article_definite(case_number: 4, singular: true),
      case_1_plural: word.case_1_plural,
      case_1_plural_article: word.article_definite(case_number: 1, singular: false),
      case_2_plural: word.case_2_plural,
      case_2_plural_article: word.article_definite(case_number: 2, singular: false),
      case_3_plural: word.case_3_plural,
      case_3_plural_article: word.article_definite(case_number: 3, singular: false),
      case_4_plural: word.case_4_plural,
      case_4_plural_article: word.article_definite(case_number: 4, singular: false),
      example_sentence: word.example_sentences.first.presence || "",
      image_url: word_image_url,
      meaning: word.meaning.presence || "",
      meaning_long: word.meaning_long.presence || "",
      syllables: word.syllables,
      written_syllables: word.written_syllables,
      topics: word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(word.hierarchy).map(&:name).join(", "),
      synonyms: word.synonyms.map(&:name).join(", "),
      rimes: word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("theme.labels.syllables"),
        keywords: I18n.t("theme.labels.keywords"),
        hierarchy: I18n.t("theme.labels.hierarchy"),
        topics: I18n.t("theme.labels.topics"),
        synonyms: I18n.t("theme.labels.synonyms"),
        rimes: I18n.t("theme.labels.rimes"),
        case_1: I18n.t("theme.labels.case_1"),
        case_2: I18n.t("theme.labels.case_2"),
        case_3: I18n.t("theme.labels.case_3"),
        case_4: I18n.t("theme.labels.case_4"),
        singular: I18n.t("theme.labels.singular"),
        plural: I18n.t("theme.labels.plural")
      }
    }
  end

  def self.verb_variables(word, word_image_url)
    {
      infinitive: word.name,
      word_type: word.class.model_name.human,
      imperative_singular: word.imperative_singular,
      imperative_plural: word.imperative_plural,
      participle: word.participle,
      past_participle: word.past_participle,
      perfect_haben: word.perfect_haben.humanize,
      perfect_sein: word.perfect_sein.humanize,
      present_singular_1: word.present_singular_1,
      present_singular_2: word.present_singular_2,
      present_singular_3: word.present_singular_3,
      present_plural_1: word.present_plural_1,
      present_plural_2: word.present_plural_2,
      present_plural_3: word.present_plural_3,
      past_singular_1: word.past_singular_1,
      past_singular_2: word.past_singular_2,
      past_singular_3: word.past_singular_3,
      past_plural_1: word.past_plural_1,
      past_plural_2: word.past_plural_2,
      past_plural_3: word.past_plural_3,
      example_sentence: word.example_sentences.first.presence || "",
      image_url: word_image_url,
      meaning: word.meaning.presence || "",
      meaning_long: word.meaning_long.presence || "",
      syllables: word.syllables,
      written_syllables: word.written_syllables,
      topics: word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(word.hierarchy).map(&:name).join(", "),
      synonyms: word.synonyms.map(&:name).join(", "),
      rimes: word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("theme.labels.syllables"),
        keywords: I18n.t("theme.labels.keywords"),
        hierarchy: I18n.t("theme.labels.hierarchy"),
        topics: I18n.t("theme.labels.topics"),
        synonyms: I18n.t("theme.labels.synonyms"),
        rimes: I18n.t("theme.labels.rimes"),
        singular: I18n.t("theme.labels.singular"),
        plural: I18n.t("theme.labels.plural"),
        singular_1_pronoun: Verb.human_attribute_name(:singular_1_pronoun),
        singular_2_pronoun: Verb.human_attribute_name(:singular_2_pronoun),
        singular_3_pronoun: Verb.human_attribute_name(:singular_3_pronoun),
        plural_1_pronoun: Verb.human_attribute_name(:plural_1_pronoun),
        plural_2_pronoun: Verb.human_attribute_name(:plural_2_pronoun),
        plural_3_pronoun: Verb.human_attribute_name(:plural_3_pronoun),
        participle: I18n.t("theme.labels.participle"),
        past_participle: I18n.t("theme.labels.past_participle"),
        present: I18n.t("theme.labels.present"),
        past: I18n.t("theme.labels.past")
      }
    }
  end

  def self.adjective_variables(word, word_image_url)
    {
      name: word.name,
      word_type: word.class.model_name.human,
      comparative: word.comparative,
      superlative: word.superlative,
      absolute: word.absolute.humanize,
      irregular_comparison: word.irregular_comparison.humanize,
      irregular_declination: word.irregular_declination.humanize,
      example_sentence: word.example_sentences.first.presence || "",
      image_url: word_image_url,
      meaning: word.meaning.presence || "",
      meaning_long: word.meaning_long.presence || "",
      syllables: word.syllables,
      written_syllables: word.written_syllables,
      topics: word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(word.hierarchy).map(&:name).join(", "),
      synonyms: word.synonyms.map(&:name).join(", "),
      rimes: word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("theme.labels.syllables"),
        keywords: I18n.t("theme.labels.keywords"),
        hierarchy: I18n.t("theme.labels.hierarchy"),
        topics: I18n.t("theme.labels.topics"),
        synonyms: I18n.t("theme.labels.synonyms"),
        rimes: I18n.t("theme.labels.rimes"),
        absolute: I18n.t("theme.labels.absolute"),
        irregular_comparison: I18n.t("theme.labels.irregular_comparison"),
        irregular_declination: I18n.t("theme.labels.irregular_declination")
      }
    }
  end
end
