# frozen_string_literal: true

class WordTypeDropdownItemComponent < ViewComponent::Base
  with_collection_parameter :word_type

  attr_reader :word_type, :counts

  def initialize(word_type:, counts:)
    @word_type = word_type
    @counts = counts
  end

  def link_title
    "#{label}&nbsp;(#{formatted_count})".html_safe
  end

  def label
    case word_type
    when :all
      t("filter.results.all_results")
    else
      word_type.model_name.human(count: 2)
    end
  end

  def formatted_count
    number_with_delimiter count
  end

  def count
    count_type = word_type == :all ? :all : word_type.model_name.plural.to_sym

    counts[count_type]
  end

  def filter_url
    new_filter = word_type == :all ? "" : word_type.model_name.name

    url_for(
      request.params.deep_merge(filterrific: {filter_type: new_filter})
    )
  end

  def has_results?
    count > 0
  end
end
