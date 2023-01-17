module PageHelper
  def label_for(word)
    case word
    when Noun
      label = "#{word.article_definite(case_number: 1, singular: true)} #{word.name}"

      if word.plural.present?
        label += ", #{word.article_definite(case_number: 1, singular: false)} #{word.plural.name}"
      end

      label
    when Adjective
      label = "#{word.name}"
      label += ", #{word.comparative.name}" if word.comparative.present?
      label += ", #{word.superlative.name}" if word.superlative.present?
      label

    when Verb
      forms = %i[
        present_singular_1 present_singular_2 present_singular_3 present_plural_1 present_plural_2 present_plural_3
        past_singular_1 past_singular_2 past_singular_3 past_plural_1 past_plural_2 past_plural_3
      ]

      label = "#{word.name}"

      forms.each do |form|
        label += ", #{word.send(form).name}" if word.send(form).present?
      end

      label

    else word.name
    end
  end
end
