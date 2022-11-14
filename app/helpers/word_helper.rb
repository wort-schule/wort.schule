# frozen_string_literal: true

module WordHelper
  def hierarchies(initial_hierarchy)
    hierarchies = [initial_hierarchy].compact
    hierarchy = hierarchies.first

    loop do
      parent = hierarchy&.parent

      break if parent.blank? || hierarchies.include?(parent)

      hierarchies << parent
    end

    hierarchies
  end

  def hierarchy_breadcrumbs(initial_hierarchy)
    hierarchies_as_links = hierarchies(initial_hierarchy).map do |hierarchy|
      link_to_if can?(:read, hierarchy), hierarchy.name, hierarchy
    end

    safe_join hierarchies_as_links.reverse, heroicon("chevron-right", options: {class: "text-gray-400"})
  end

  def separate(items)
    return if items.blank?

    content_tag :div, class: "flex flex-wrap gap-2" do
      items.each.with_index do |item, index|
        concat content_tag :span, "•", class: "text-gray-400" if index != 0
        yield item
      end
    end
  end

  def any_present?(model, attributes)
    return true unless Rails.configuration.hide_blank_items

    attributes.any? do |attribute|
      model.public_send(attribute).present?
    end
  end
end
