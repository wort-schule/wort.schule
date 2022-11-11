# frozen_string_literal: true

class ThemeComponent < ViewComponent::Base
  include WordHelper

  def initialize(word:, theme:, default:)
    @word = word
    @theme = theme
    @default = default
  end

  def before_render
    @word_image_url = url_for @word.image if @word.image.attached?
  end

  def liquid_template
    template = @default ? File.read(Rails.root.join("app/views/themes/default_#{word_type}.liquid")) : @theme.template
    template_renderer = Liquid::Template.parse(template)
    template_renderer.render(params.with_indifferent_access).html_safe
  end

  private

  def word_type
    @word.model_name.singular.underscore
  end

  def params
    case @word
    when Noun then noun_params
    when Verb then verb_params
    when Adjective then adjective_params
    end
  end

  def noun_params
    {
      name: @word.name,
      word_type: @word.class.model_name.human,
      singular: @word.name,
      plural: @word.plural,
      case_1_singular: @word.case_1_singular,
      case_1_singular_article: @word.article_definite(case_number: 1, singular: true),
      case_2_singular: @word.case_2_singular,
      case_2_singular_article: @word.article_definite(case_number: 2, singular: true),
      case_3_singular: @word.case_3_singular,
      case_3_singular_article: @word.article_definite(case_number: 3, singular: true),
      case_4_singular: @word.case_4_singular,
      case_4_singular_article: @word.article_definite(case_number: 4, singular: true),
      case_1_plural: @word.case_1_plural,
      case_1_plural_article: @word.article_definite(case_number: 1, singular: false),
      case_2_plural: @word.case_2_plural,
      case_2_plural_article: @word.article_definite(case_number: 2, singular: false),
      case_3_plural: @word.case_3_plural,
      case_3_plural_article: @word.article_definite(case_number: 3, singular: false),
      case_4_plural: @word.case_4_plural,
      case_4_plural_article: @word.article_definite(case_number: 4, singular: false),
      example_sentence: @word.example_sentences.first.presence || "",
      image_url: @word_image_url,
      meaning: @word.meaning.presence || "",
      meaning_long: @word.meaning_long.presence || "",
      syllables: @word.syllables,
      written_syllables: @word.written_syllables,
      topics: @word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(@word.hierarchy).map(&:name).join(", "),
      synonyms: @word.synonyms.map(&:name).join(", "),
      rimes: @word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("card.labels.syllables"),
        keywords: I18n.t("card.labels.keywords"),
        hierarchy: I18n.t("card.labels.hierarchy"),
        topics: I18n.t("card.labels.topics"),
        synonyms: I18n.t("card.labels.synonyms"),
        rimes: I18n.t("card.labels.rimes"),
        case_1: I18n.t("card.labels.case_1"),
        case_2: I18n.t("card.labels.case_2"),
        case_3: I18n.t("card.labels.case_3"),
        case_4: I18n.t("card.labels.case_4"),
        singular: I18n.t("card.labels.singular"),
        plural: I18n.t("card.labels.plural")
      }
    }
  end

  def verb_params
    {
      infinitive: @word.name,
      word_type: @word.class.model_name.human,
      imperative_singular: @word.imperative_singular,
      imperative_plural: @word.imperative_plural,
      participle: @word.participle,
      past_participle: @word.past_participle,
      perfect_haben: @word.perfect_haben.humanize,
      perfect_sein: @word.perfect_sein.humanize,
      present_singular_1: @word.present_singular_1,
      present_singular_2: @word.present_singular_2,
      present_singular_3: @word.present_singular_3,
      present_plural_1: @word.present_plural_1,
      present_plural_2: @word.present_plural_2,
      present_plural_3: @word.present_plural_3,
      past_singular_1: @word.past_singular_1,
      past_singular_2: @word.past_singular_2,
      past_singular_3: @word.past_singular_3,
      past_plural_1: @word.past_plural_1,
      past_plural_2: @word.past_plural_2,
      past_plural_3: @word.past_plural_3,
      example_sentence: @word.example_sentences.first.presence || "",
      image_url: @word_image_url,
      meaning: @word.meaning.presence || "",
      meaning_long: @word.meaning_long.presence || "",
      syllables: @word.syllables,
      written_syllables: @word.written_syllables,
      topics: @word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(@word.hierarchy).map(&:name).join(", "),
      synonyms: @word.synonyms.map(&:name).join(", "),
      rimes: @word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("card.labels.syllables"),
        keywords: I18n.t("card.labels.keywords"),
        hierarchy: I18n.t("card.labels.hierarchy"),
        topics: I18n.t("card.labels.topics"),
        synonyms: I18n.t("card.labels.synonyms"),
        rimes: I18n.t("card.labels.rimes"),
        singular: I18n.t("card.labels.singular"),
        plural: I18n.t("card.labels.plural"),
        singular_1_pronoun: Verb.human_attribute_name(:singular_1_pronoun),
        singular_2_pronoun: Verb.human_attribute_name(:singular_2_pronoun),
        singular_3_pronoun: Verb.human_attribute_name(:singular_3_pronoun),
        plural_1_pronoun: Verb.human_attribute_name(:plural_1_pronoun),
        plural_2_pronoun: Verb.human_attribute_name(:plural_2_pronoun),
        plural_3_pronoun: Verb.human_attribute_name(:plural_3_pronoun),
        participle: I18n.t("card.labels.participle"),
        past_participle: I18n.t("card.labels.past_participle"),
        present: I18n.t("card.labels.present"),
        past: I18n.t("card.labels.past")
      }
    }
  end

  def adjective_params
    {
      name: @word.name,
      word_type: @word.class.model_name.human,
      comparative: @word.comparative,
      superlative: @word.superlative,
      absolute: @word.absolute.humanize,
      irregular_comparison: @word.irregular_comparison.humanize,
      irregular_declination: @word.irregular_declination.humanize,
      example_sentence: @word.example_sentences.first.presence || "",
      image_url: @word_image_url,
      meaning: @word.meaning.presence || "",
      meaning_long: @word.meaning_long.presence || "",
      syllables: @word.syllables,
      written_syllables: @word.written_syllables,
      topics: @word.topics.map(&:name).join(", "),
      hierarchies: hierarchies(@word.hierarchy).map(&:name).join(", "),
      synonyms: @word.synonyms.map(&:name).join(", "),
      rimes: @word.rimes.map(&:name).join(", "),
      labels: {
        syllables: I18n.t("card.labels.syllables"),
        keywords: I18n.t("card.labels.keywords"),
        hierarchy: I18n.t("card.labels.hierarchy"),
        topics: I18n.t("card.labels.topics"),
        synonyms: I18n.t("card.labels.synonyms"),
        rimes: I18n.t("card.labels.rimes"),
        absolute: I18n.t("card.labels.absolute"),
        irregular_comparison: I18n.t("card.labels.irregular_comparison"),
        irregular_declination: I18n.t("card.labels.irregular_declination")
      }
    }
  end
end
