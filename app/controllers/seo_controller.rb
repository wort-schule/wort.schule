class SeoController < PublicController
  def word_index
    @letter = params[:letter] || "a"
    @words = words_with_variants

    respond_to do |format|
      format.html
      format.json
    end
  end

  # Returns all words in the database that start with the given letter, including all variants like plural,
  # comparative, etc. and sorted by the word itself. Also ensures that the same word is not included multiple times.
  private def words_with_variants
    # TODO: case_X singular and plural?
    %i[
      name
      case_1_singular case_2_singular case_3_singular case_4_singular case_1_plural case_2_plural case_3_plural
      case_4_plural plural
      comparative superlative
      imperative_singular imperative_plural participle past_participle
      present_singular_1 present_singular_2 present_singular_3 present_plural_1 present_plural_2 present_plural_3
      past_singular_1 past_singular_2 past_singular_3 past_plural_1 past_plural_2 past_plural_3
    ]
      .map { |field| Word.where("#{field} ILIKE ?", "#{@letter}%").map { |w| build_word_hash(w, field) } }
      .flatten
      .uniq { |w| w[:label] }
      .sort_by { |w| w[:label].downcase }
  end

  # Generates a simple hash for the given word and field as a data object for the view.
  private def build_word_hash(word, field)
    suffix = if field == :plural
      ", die"
    elsif word.is_a?(Noun)
      case_number = field.starts_with?("case_") ? field.to_s.split("_")[1].to_i : 1
      singular = field.ends_with?("singular") || field == :name
      ", #{word.article_definite(case_number: case_number, singular: singular)}"
    else
      ""
    end

    {
      label: word.send(field) + suffix,
      word_type_label: word_type_label(word, field),
      base_record: word
    }
  end

  # Generates a human readable label for the given word type.
  private def word_type_label(word, field)
    if field == :name
      t("activerecord.models.#{word.class.name.downcase}.one")
    else
      "#{t("seo.word_index.fields.#{field}")} #{t("seo.word_index.of")} #{word.name}"
    end
  end
end
