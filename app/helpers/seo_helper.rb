module SeoHelper
  def label_for(word)
    case word
    when Noun
      label = "#{word.article_definite(case_number: 1, singular: true)} #{word.name}"
      label += ", #{word.article_definite(case_number: 1, singular: false)} #{word.plural}" if word.plural.present?

      label
    when Adjective
      label = word.name.to_s
      label += ", #{word.comparative}" if word.comparative.present?
      label += ", #{word.superlative}" if word.superlative.present?
      label

    when Verb
      forms = %i[
        present_singular_1 present_singular_2 present_singular_3 present_plural_1 present_plural_2 present_plural_3
        past_singular_1 past_singular_2 past_singular_3 past_plural_1 past_plural_2 past_plural_3
      ]

      label = word.name.to_s

      forms.each do |form|
        label += ", #{word.send(form)}" if word.send(form).present?
      end

      label

    else word.name
    end
  end
end
