# frozen_string_literal: true

module PendingReviewsHelper
  def sortable_link(title, sort_column, current_sort, current_direction)
    direction = if current_sort == sort_column && current_direction == "desc"
      "asc"
    else
      "desc"
    end

    params_copy = params.permit(:sort_by, :sort_direction).to_h
    params_copy[:sort_by] = sort_column
    params_copy[:sort_direction] = direction

    link_to pending_reviews_path(params_copy), class: "hover:underline cursor-pointer" do
      concat title
      if current_sort == sort_column
        concat " "
        arrow = ((direction == "desc") ? "↓" : "↑")
        concat arrow
      end
    end
  end

  def truncate_value(value)
    case value
    when String
      truncate(value, length: 40)
    when Array
      truncate(value.map(&:to_s).join(", "), length: 40)
    when Hash
      truncate(value.to_s, length: 40)
    else
      truncate(value.to_s, length: 40)
    end
  end

  def format_proposed_attribute(edit)
    proposed = edit.proposed_value
    attribute_name = edit.attribute_name

    # List of association attributes that should display names instead of IDs
    association_attributes = %w[keywords synonyms opposites rimes topics strategies phenomenons]
    return truncate_value(proposed) unless association_attributes.include?(attribute_name)

    # Extract IDs from proposed values
    ids = extract_ids_from_proposed(proposed)
    return truncate_value(proposed) if ids.empty?

    # Fetch and display the actual names based on the attribute type
    names = case attribute_name
    when "keywords", "synonyms", "opposites", "rimes"
      Word.where(id: ids).pluck(:name).sort
    when "topics"
      Topic.where(id: ids).pluck(:name).sort
    when "strategies"
      Strategy.where(id: ids).pluck(:name).sort
    when "phenomenons"
      Phenomenon.where(id: ids).pluck(:name).sort
    else
      []
    end

    truncate(names.join(", "), length: 120)
  end

  private

  def extract_ids_from_proposed(proposed)
    case proposed
    when Array
      proposed.select { |item| item.is_a?(Integer) || (item.is_a?(String) && item.to_i.to_s == item) }
        .map { |item| item.is_a?(Integer) ? item : item.to_i }
    when String
      proposed.split(",").map(&:strip).map(&:to_i).reject(&:zero?)
    else
      []
    end
  end
end
