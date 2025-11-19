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
end
