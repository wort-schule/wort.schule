# frozen_string_literal: true

class ThemeVariables
  extend WordHelper

  def self.noun_keys
    (noun_variables(Noun.new, "", nil).keys - %i[labels]).sort
  end

  def self.verb_keys
    (verb_variables(Verb.new, "", nil).keys - %i[labels]).sort
  end

  def self.adjective_keys
    (adjective_variables(Adjective.new, "", nil).keys - %i[labels]).sort
  end

  def self.function_word_keys
    (function_word_variables(FunctionWord.new, "", nil).keys - %i[labels]).sort
  end

  def self.shared_labels
    {
      syllables: I18n.t("theme.labels.syllables"),
      keywords: I18n.t("theme.labels.keywords"),
      hierarchy: I18n.t("theme.labels.hierarchy"),
      topics: I18n.t("theme.labels.topics"),
      synonyms: I18n.t("theme.labels.synonyms"),
      rimes: I18n.t("theme.labels.rimes")
    }
  end

  def self.shared_variables(word, word_image_url, view_context)
    {
      compound_entities_separated: view_context&.controller&.render_to_string(partial: "words/compound_entities", locals: {word:}),
      compound: word.compound&.humanize,
      example_sentences_box: view_context&.controller&.render_to_string(partial: "example_sentences/list", locals: {word:}),
      example_sentence: word.example_sentences.first.presence || "",
      foreign: word.foreign&.humanize,
      hierarchies: hierarchies(word.hierarchy).map(&:name).join(", "),
      hierarchy_breadcrumbs: view_context&.controller&.render_to_string(partial: "words/hierarchies", locals: {word:}),
      image_url: word_image_url,
      keywords_separated: view_context&.controller&.render_to_string(partial: "words/keywords", locals: {word:}),
      lists_box: view_context&.controller&.render_to_string(partial: "words/lists", locals: {word:, current_user: view_context.current_user, current_ability: view_context.current_ability}),
      meaning_long: word.meaning_long.presence || "",
      meaning: word.meaning.presence || "",
      opposites_separated: view_context&.controller&.render_to_string(partial: "words/opposites", locals: {word:}),
      other_meanings_box: view_context&.controller&.render_to_string(partial: "words/more_meanings", locals: {word:}),
      phenomenons_separated: view_context&.controller&.render_to_string(partial: "words/phenomenons", locals: {word:}),
      postfix: word.postfix&.name,
      prefix: word.prefix&.name,
      prototype: word.prototype&.humanize,
      rimes_separated: view_context&.controller&.render_to_string(partial: "words/rimes", locals: {word:}),
      rimes: word.rimes.map(&:name).join(", "),
      strategies_separated: view_context&.controller&.render_to_string(partial: "words/strategies", locals: {word:}),
      syllables: word.syllables,
      synonyms_separated: view_context&.controller&.render_to_string(partial: "words/synonyms", locals: {word:}),
      synonyms: word.synonyms.map(&:name).join(", "),
      topics_separated: view_context&.controller&.render_to_string(partial: "words/topics", locals: {word:}),
      topics: word.topics.map(&:name).join(", "),
      word_type: word.class.model_name.human,
      written_syllables: word.written_syllables
    }
  end

  def self.noun_variables(word, word_image_url, view_context)
    {
      **shared_variables(word, word_image_url, view_context),
      singular: word.name,
      plural: word.plural,
      genus_neuter: word.genus_neuter&.name,
      genus_masculine: word.genus_masculine&.name,
      genus_feminine: word.genus_feminine&.name,
      singularetantum: word.singularetantum&.humanize,
      pluraletantum: word.pluraletantum&.humanize,
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
      header: view_context&.controller&.render_to_string(partial: "nouns/header", locals: {noun: word, current_user: view_context&.current_user}),
      labels: {
        **shared_labels,
        singularetantum: Numerus.singularetantum(view_context&.current_numerus_wording),
        pluraletantum: Numerus.pluraletantum(view_context&.current_numerus_wording),
        case_1: I18n.t("theme.labels.case_1"),
        case_2: I18n.t("theme.labels.case_2"),
        case_3: I18n.t("theme.labels.case_3"),
        case_4: I18n.t("theme.labels.case_4"),
        singular: Numerus.singular(view_context&.current_numerus_wording),
        plural: Numerus.plural(view_context&.current_numerus_wording)
      }
    }
  end

  def self.verb_variables(word, word_image_url, view_context)
    {
      **shared_variables(word, word_image_url, view_context),
      infinitive: word.name,
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
      subjectless: word.subjectless.humanize,
      strong: word.strong.humanize,
      header: view_context&.controller&.render_to_string(partial: "verbs/header", locals: {verb: word, current_user: view_context&.current_user}),
      labels: {
        **shared_labels,
        singular: Numerus.singular(view_context&.current_numerus_wording),
        plural: Numerus.plural(view_context&.current_numerus_wording),
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

  def self.adjective_variables(word, word_image_url, view_context)
    {
      **shared_variables(word, word_image_url, view_context),
      name: word.name,
      comparative: word.comparative,
      superlative: word.superlative,
      absolute: word.absolute.humanize,
      irregular_comparison: word.irregular_comparison.humanize,
      irregular_declination: word.irregular_declination.humanize,
      header: view_context&.controller&.render_to_string(partial: "adjectives/header", locals: {adjective: word, current_user: view_context&.current_user}),
      labels: {
        **shared_labels,
        absolute: I18n.t("theme.labels.absolute"),
        irregular_comparison: I18n.t("theme.labels.irregular_comparison"),
        irregular_declination: I18n.t("theme.labels.irregular_declination")
      }
    }
  end

  def self.function_word_variables(word, word_image_url, view_context)
    {
      name: word.name,
      word_type: word.class.model_name.human,
      function_type: word.function_type_text,
      syllables: word.syllables,
      written_syllables: word.written_syllables,
      header: view_context&.controller&.render_to_string(partial: "function_words/header", locals: {function_word: word, current_user: view_context&.current_user}),
      labels: {
        syllables: I18n.t("theme.labels.syllables")
      }
    }
  end
end
