# frozen_string_literal: true

module WordFilter
  extend ActiveSupport::Concern

  class_methods do
    def replace_regex(query)
      squeeze query
        .tr("*", "%")
        .tr("?", "_")
    end

    def squeeze(query)
      query.squeeze(" ").strip
    end

    def filter_with_conjunction(attribute, options)
      options[attribute]&.select!(&:present?)
      return if options[attribute].blank?

      if options.conjunction == "and"
        filtered_words = Word.joins(attribute)
          .where(attribute => {id: options[attribute]})
          .group("words.id")
          .having("COUNT(*) = #{options[attribute].length}")
          .unscope(:order)
          .distinct

        where("words.id": filtered_words)
      else
        where(
          "words.id": Word.joins(attribute)
          .where(attribute => {id: options[attribute]})
        )
      end
    end

    def filter_boolean(attribute, query, join_table: nil)
      return if query.blank?

      if query.to_s == "yes"
        where(attribute => true)
      elsif query.to_s == "no"
        where(attribute => false)
      end
    end
  end

  included do
    filterrific(
      available_filters: [
        :filter_type,
        :filter_smart,
        :filter_home,
        :filter_wordstarts,
        :filter_wordends,
        :filter_wordcontains,
        :filter_letters,
        :filter_syllablescontains,
        :filter_cologne_phonetics,
        :filter_source,
        :filter_topic,
        :filter_hierarchy,
        :filter_phenomenons,
        :filter_strategies,
        :filter_keywords,
        :filter_consonant_vowel,
        :filter_example_sentences,
        :filter_foreign,
        :filter_prototype,
        :filter_compound,
        :filter_singularetantum,
        :filter_pluraletantum,
        :filter_subjectless,
        :filter_perfect_haben,
        :filter_perfect_sein,
        :filter_modal,
        :filter_strong,
        :filter_irregular_declination,
        :filter_absolute,
        :filter_irregular_comparison,
        :filter_images,
        :filter_letter_count,
        :filter_syllables_count
      ]
    )

    scope :filter_type, lambda { |type|
      return if type.blank?

      where(type:)
    }

    scope :filter_smart, lambda { |query|
      return if query.blank?

      query = squeeze query
      term = replace_regex query

      Word.union(
        filter_wordquery("%#{query}%"),
        where("plural ILIKE ?", term),
        where("comparative ILIKE ?", term),
        where("superlative ILIKE ?", term),
        filter_cologne_phonetics(query)
      )
    }

    scope :filter_home, lambda { |query|
      count = !query&.is_a?(String) && query&.dig(:count)
      query = query&.dig(:query) if count

      return if query.blank?

      query = squeeze query
      term = replace_regex query

      # The additional `JOIN` query is necessary, because `union` does not
      # return unique elements because of the added `weights`. If a word
      # appears in a result with different weights, it appears twice. Therefore
      # we add another query to deduplicate them. Take care though that
      # `where(id: ..)` is not stable and we therefore need to enforce the
      # original order.
      ids = Word.union(
        filter_wordquery(query).select("*, 1 as weight"),
        filter_wordquery("#{query}%").select("*, 2 as weight"),
        filter_wordquery("%#{query}%").select("*, 3 as weight"),
        where("plural ILIKE ?", term).select("*, 1 as weight"),
        where("plural ILIKE ?", "#{query}%").select("*, 2 as weight"),
        where("comparative ILIKE ?", term).select("*, 1 as weight"),
        where("comparative ILIKE ?", "#{query}%").select("*, 2 as weight"),
        where("superlative ILIKE ?", term).select("*, 1 as weight"),
        where("superlative ILIKE ?", "#{query}%").select("*, 2 as weight"),
        filter_cologne_phonetics(query).select("*, 4 as weight")
      ).order(:weight, :name).ids.uniq

      Word
        .joins(Arel.sql("JOIN unnest('{#{ids.join(",")}}'::bigint[]) WITH ORDINALITY t(id, ord) ON t.id = words.id"))
        .order(count ? nil : Arel.sql("t.ord"))
    }

    scope :filter_wordquery, lambda { |query|
      return if query.blank?

      query = squeeze query
      term = replace_regex query
      where("words.name ILIKE ?", term)
    }

    scope :filter_wordstarts, lambda { |query|
      filter_wordquery "#{query}%"
    }

    scope :filter_wordends, lambda { |query|
      filter_wordquery "%#{query}"
    }

    scope :filter_wordcontains, lambda { |query|
      filter_wordquery "%#{query}%"
    }

    scope :filter_syllablescontains, lambda { |query|
      return if query.blank?

      query = squeeze query
      query = replace_regex query
      syllables_terms = [
        "#{query}-%",
        "%-#{query}-%",
        "%-#{query}"
      ]
      written_syllables_terms = [
        "#{query}|%",
        "%|#{query}|%",
        "%|#{query}"
      ]

      where(
        [
          (["syllables ILIKE ?"] * syllables_terms.count).join(" OR "),
          (["written_syllables ILIKE ?"] * written_syllables_terms.count).join(" OR ")
        ].join(" OR "),
        *syllables_terms,
        *written_syllables_terms
      )
    }

    scope :filter_letter_count, lambda { |query|
      return if query.blank?

      where("char_length(regexp_replace(words.name, '\s', '', 'g')) = ?", query)
    }

    scope :filter_syllables_count, lambda { |query|
      return if query.blank?

      where("regexp_replace(words.syllables, '\s', '', 'g') != '' AND array_length(regexp_split_to_array(words.syllables, '-'), 1) = ?", query)
    }

    scope :filter_cologne_phonetics, lambda { |query|
      return if query.blank?

      query = squeeze query
      where("? = ANY(cologne_phonetics)", ColognePhonetics.encode(query))
    }

    scope :filter_letters, lambda { |query|
      return if query.blank?

      query = squeeze query
      letters = query
        .gsub(/[^[:alpha:]]/, "")
        .chars
        .uniq

      where("words.name ~* ?", letters.map { |letter| "(?=.*#{letter})" }.join)
    }

    scope :filter_source, lambda { |source|
      return if source.blank?

      where(
        "words.id": Word.joins(:sources)
        .where("sources.id": source)
      )
    }

    scope :filter_topic, lambda { |topic|
      return if topic.blank?

      where(
        "words.id": Word
        .joins(:topics)
        .where(topics: {id: topic})
      )
    }

    scope :filter_hierarchy, lambda { |hierarchy|
      return if hierarchy.blank?

      where(hierarchy:)
    }

    scope :filter_phenomenons, lambda { |options|
      filter_with_conjunction(:phenomenons, options)
    }

    scope :filter_strategies, lambda { |options|
      filter_with_conjunction(:strategies, options)
    }

    scope :filter_keywords, lambda { |options|
      filter_with_conjunction(:keywords, options)
    }

    scope :filter_consonant_vowel, lambda { |query|
      return if query.blank?

      where(consonant_vowel: query.upcase)
    }

    scope :filter_foreign, lambda { |query|
      filter_boolean(:foreign, query)
    }

    scope :filter_prototype, lambda { |query|
      filter_boolean :prototype, query
    }

    scope :filter_compound, lambda { |query|
      filter_boolean :compound, query
    }

    scope :filter_example_sentences, lambda { |query|
      return if query.blank?

      if query.to_s == "yes"
        where.not(
          "words.id": Word
          .where("example_sentences = '[]'")
        )
      elsif query.to_s == "no"
        where(
          "words.id": Word
          .where("example_sentences = '[]'")
        )
      end
    }

    scope :filter_singularetantum, lambda { |query|
      filter_boolean :singularetantum, query, join_table: :nouns
    }

    scope :filter_pluraletantum, lambda { |query|
      filter_boolean :pluraletantum, query, join_table: :nouns
    }

    scope :filter_subjectless, lambda { |query|
      filter_boolean :subjectless, query, join_table: :verbs
    }

    scope :filter_perfect_haben, lambda { |query|
      filter_boolean :perfect_haben, query, join_table: :verbs
    }

    scope :filter_perfect_sein, lambda { |query|
      filter_boolean :perfect_sein, query, join_table: :verbs
    }

    scope :filter_modal, lambda { |query|
      filter_boolean :modal, query, join_table: :verbs
    }

    scope :filter_strong, lambda { |query|
      filter_boolean :strong, query, join_table: :verbs
    }

    scope :filter_irregular_declination, lambda { |query|
      filter_boolean :irregular_declination, query, join_table: :adjectives
    }

    scope :filter_absolute, lambda { |query|
      filter_boolean :absolute, query, join_table: :adjectives
    }

    scope :filter_irregular_comparison, lambda { |query|
      filter_boolean :irregular_comparison, query, join_table: :adjectives
    }

    scope :filter_images, lambda { |query|
      return if query.blank?

      if query.to_s == "yes"
        joins(:image_attachment)
      elsif query.to_s == "no"
        where.missing(:image_attachment)
      end
    }
  end
end
