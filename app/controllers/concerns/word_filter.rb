# frozen_string_literal: true

module WordFilter
  extend ActiveSupport::Concern

  class_methods do
    def replace_regex(query)
      query
        .tr("*", "%")
        .tr("?", "_")
    end

    def filter_with_conjunction(attribute, options)
      options[attribute]&.select!(&:present?)
      return if options[attribute].blank?

      if options.conjunction == "and"
        filtered_words = Word.joins(attribute)
          .where(attribute => {id: options[attribute]})
          .group("words.id")
          .having("COUNT(*) = #{options[attribute].length}")
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
      return if query.to_s != "1"

      where(attribute => true)
    end
  end

  included do
    filterrific(
      available_filters: [
        :filter_type,
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
        :filter_irregular_comparison
      ]
    )

    scope :filter_type, lambda { |type|
      where(type: type.presence || "")
    }

    scope :filter_wordquery, lambda { |query|
      return if query.blank?

      term = replace_regex query
      where("name ILIKE ?", term)
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

    scope :filter_cologne_phonetics, lambda { |query|
      return if query.blank?

      where("cologne_phonetics ILIKE ?", "#{ColognePhonetics.encode(query)}%")
    }

    scope :filter_letters, lambda { |query|
      return if query.blank?

      letters = query
        .gsub(/[^[:alpha:]]/, "")
        .chars
        .uniq

      where("name ~* ?", letters.map { |letter| "(?=.*#{letter})" }.join)
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
      return if query.to_s != "1"

      where.not(
        "words.id": Word
        .where("example_sentences = '[]'")
      )
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
  end
end
