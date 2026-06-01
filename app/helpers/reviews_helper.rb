# frozen_string_literal: true

module ReviewsHelper
  # Builds the ordered filter segments for the review page: new words first,
  # then the remaining types by descending pending count. Each segment is a
  # hash with :review_type, :label, :count and :active.
  def review_filter_segments(user, counts)
    selected = user.review_attributes_without_types

    attribute_segments = counts.except("new_word").map do |attribute_name, count|
      {
        review_type: attribute_name,
        label: review_attribute_labels[attribute_name] || attribute_name,
        count: count,
        active: selected.include?(attribute_name)
      }
    end.sort_by { |segment| -segment[:count] }

    new_word_segments = if counts["new_word"].to_i.positive?
      [{
        review_type: "new_word",
        label: t("reviews.filter.new_word"),
        count: counts["new_word"],
        active: user.review_new_words?
      }]
    else
      []
    end

    new_word_segments + attribute_segments
  end

  def review_filter_segment_class(active)
    base = "flex items-center gap-2 rounded-lg border-2 px-3 py-2 text-sm font-medium"

    if active
      "#{base} border-primary bg-primary/5 text-primary"
    else
      "#{base} border-gray-200 bg-white text-gray-600 hover:bg-gray-50"
    end
  end

  def review_filter_badge_class(active)
    base = "rounded-full px-2 py-0.5 text-xs font-semibold"

    active ? "#{base} bg-primary text-white" : "#{base} bg-gray-200 text-gray-700"
  end

  private

  # Maps a bare attribute_name (e.g. "keywords") to its human label
  # (e.g. "Stichwörter"), keeping the first label per attribute.
  def review_attribute_labels
    Llm::Attributes.collection.each_with_object({}) do |(title, key), map|
      map[key.split(".").last] ||= title
    end
  end
end
