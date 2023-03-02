# frozen_string_literal: true

class WordTypeFilterComponent < ViewComponent::Base
  with_collection_parameter :word_type

  attr_reader :word_type, :counts, :form

  def initialize(word_type:, counts:, f:)
    @word_type = word_type
    @counts = counts
    @form = f
  end

  def label
    case word_type
    when :all
      t("filter.results.all", count: formatted_count)
    else
      t("filter.results.#{word_type.model_name.plural}", count: formatted_count)
    end
  end

  def formatted_count
    number_with_delimiter count
  end

  def count
    count_type = word_type == :all ? :all : word_type.model_name.plural.to_sym

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

  def filter_callback
    case word_type
    when :all
      "hideAll"
    else
      "show#{word_type.model_name.name}"
    end
  end

  def has_results?
    count > 0
  end
end
