# frozen_string_literal: true

module SeoHelper
  def label_for(word)
    return word.name unless word.name === Noun

    article_singular = word.article_definite(case_number: 1, singular: true)
    "#{word.name}#{article_singular.present? ? ", #{article_singular}" : ""}"
  end

  def variants_for(word)
    variant_fields = %i[
      comparative superlative
      present_singular_1 present_singular_2 present_singular_3 present_plural_1 present_plural_2 present_plural_3
      past_singular_1 past_singular_2 past_singular_3 past_plural_1 past_plural_2 past_plural_3
    ]

    variants = [label_for(word)]
    variants << variant_fields.map { |v| word.send(v) }.reject(&:blank?)

    # Plural needs special treatment due to the article
    variants << "#{word.plural}, #{word.article_definite(case_number: 1, singular: false)}" if word.plural.present?

    variants.flatten
  end
end
