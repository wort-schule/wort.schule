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
    template = @default ? File.read(Rails.root.join("app/views/themes/default_noun.liquid")) : @theme.template
    template_renderer = Liquid::Template.parse(template)
    template_renderer.render(params.with_indifferent_access).html_safe
  end

  private

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
      name: @word.name
    }
  end

  def adjective_params
    {
      name: @word.name
    }
  end
end
