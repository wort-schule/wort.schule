class SeoController < PublicController
  def word_index
    @letter = params[:letter] || "a"
    @words = words_with_variants
  end

  # Returns all words in the database that start with the given letter, including all variants like plural,
  # comparative, etc. and sorted by the word itself.
  private def words_with_variants
    # TODO: case_X singular and plural?
    %i[
      name
      plural comparative superlative
      imperative_singular imperative_plural participle past_participle
      present_singular_1 present_singular_2 present_singular_3 present_plural_1 present_plural_2 present_plural_3
      past_singular_1 past_singular_2 past_singular_3 past_plural_1 past_plural_2 past_plural_3
    ]
      .map { |field| Word.where("#{field} ILIKE ?", "#{@letter}%").map { |w| build_word_hash(w, field) } }
      .flatten
      .sort_by { |w| w[:label].downcase }
  end

  # Generates a simple hash for the given word and field as a data object for the view.
  private def build_word_hash(word, field)
    suffix = if field == :plural
      ", die"
    elsif word.is_a?(Noun) && field == :name
      ", #{word.article_definite(case_number: 1, singular: true)}"
    else
      ""
    end

    {
      label: word.send(field) + suffix,
      word_type_label: word_type_label(word, field),
      base_record: word
    }
  end

  # TODO: Better translations
  # Generates a human readable label for the given word type.
  private def word_type_label(word, field)
    if field == :name
      t("activerecord.models.#{word.class.name.downcase}.one")
    else
      t("theme.descriptions.#{field}_html") + " von #{word.name}"
    end
  end
end
