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
        if block_given?
          yield item
        else
          concat item
        end
      end
    end
  end

  def separate_concat(items)
    return if items.blank?

    content_tag :div, class: "flex flex-wrap gap-2" do
      items.each.with_index do |item, index|
        concat content_tag :span, "•", class: "text-gray-400" if index != 0
        concat item
      end
    end
  end

  def any_present?(model, attributes)
    return true unless Rails.configuration.hide_blank_items

    attributes.any? do |attribute|
      model.public_send(attribute).present?
    end
  end

  def with_article(word)
    return word.name if !word.is_a?(Noun) || word.type != "Noun"

    content_tag :div, "", class: "flex gap-1 items-baseline" do
      concat content_tag(:div, word.article_definite(case_number: 1, singular: true), class: "text-sm text-gray-400")
      concat content_tag(:span, word.name)
    end
  end

  def word_count_for(word_type)
    initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: word_type, filter_home: {count: true, query: params.dig(:filterrific, :filter_home)})
    ).find.size
  end
end
