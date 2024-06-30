# frozen_string_literal: true

class WordTypeFilterComponent < ViewComponent::Base
  with_collection_parameter :word_type

  attr_reader :word_type, :counts, :current_word_type, :current_word_type_wording

  def initialize(word_type:, counts:, current_word_type:, current_word_type_wording:)
    @word_type = word_type
    @counts = counts
    @current_word_type = current_word_type.to_s
    @current_word_type_wording = current_word_type_wording
  end

  def label
    case word_type
    when :all
      t("filter.results.all", count: formatted_count)
    else
      word_type_label = WordTypes.label(
        current_word_type_wording,
        word_type.model_name.name,
        plural: count != 1
      )

      t("filter.results.word_type", word_type: word_type_label, count: formatted_count)
    end
  end

  def formatted_count
    number_with_delimiter count
  end

  def count
    count_type = (word_type == :all) ? :all : word_type.model_name.plural.to_sym

    counts[count_type]
  end

  def value
    case word_type
    when :all
      ""
    else
      word_type.model_name.name
    end
  end

  def has_results?
    count > 0
  end
end
