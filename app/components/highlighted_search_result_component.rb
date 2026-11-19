# frozen_string_literal: true

class HighlightedSearchResultComponent < ViewComponent::Base
  attr_reader :result, :query

  def initialize(result:, query:)
    @result = result
    @query = query
  end

  def parts
    @parts ||= compute_parts
  end

  def hit_in
    return @hit_in if defined?(@hit_in)
    @hit_in = compute_hit_in
  end

  # The query is user input: escape it so it is matched as plain text.
  def query_pattern
    @query_pattern ||= Regexp.new(Regexp.escape(query.to_s), Regexp::IGNORECASE)
  end

  private

  def compute_parts
    return [] if query.blank?
    return [result.name] unless /^[[:alpha:]]*$/.match?(query)

    result
      .public_send(hit_in)
      .split(/(#{query_pattern})/)
      .select(&:present?)
      .map do |part|
        part.gsub(" ", "&nbsp;")
      end
  end

  def compute_hit_in
    return :full_name if result.name&.match?(query_pattern)
    return :full_plural if result.plural&.match?(query_pattern)
    return :comparative if result.comparative&.match?(query_pattern)
    return :superlative if result.superlative&.match?(query_pattern)
    :full_name if result.cologne_phonetics&.any? do |term|
      term.match?(ColognePhonetics.encode(query))
    end
  end
end
