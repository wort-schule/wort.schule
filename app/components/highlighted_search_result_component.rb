# frozen_string_literal: true

class HighlightedSearchResultComponent < ViewComponent::Base
  attr_reader :result, :query

  def initialize(result:, query:)
    @result = result
    @query = query
  end

  def parts
    return [] if query.blank?
    return [result.name] unless /^[[:alpha:]]*$/.match?(query)

    result
      .public_send(hit_in)
      .split(/(#{query})/i)
      .select(&:present?)
      .map do |part|
        part.gsub(" ", "&nbsp;")
      end
  end

  def hit_in
    return :full_name if result.name&.match?(/#{query}/i)
    return :full_plural if result.plural&.match?(/#{query}/i)
    return :comparative if result.comparative&.match?(/#{query}/i)
    return :superlative if result.superlative&.match?(/#{query}/i)
    :full_name if result.cologne_phonetics&.any? do |term|
      term.match?(ColognePhonetics.encode(query))
    end
  end
end
