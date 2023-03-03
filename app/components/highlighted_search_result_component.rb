# frozen_string_literal: true

class HighlightedSearchResultComponent < ViewComponent::Base
  attr_reader :result, :query

  def initialize(result:, query:)
    @result = result
    @query = query
  end

  def parts
    return [result] unless /^[[:alpha:]]*$/.match?(query)

    result.split(/(#{query})/i).select(&:present?)
  end
end
