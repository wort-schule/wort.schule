# frozen_string_literal: true

class BoxDescriptionListItemComponent < ViewComponent::Base
  def initialize(label:, content_class:)
    @label = label
    @content_class = content_class
  end

  def render?
    return true unless Rails.configuration.hide_blank_items

    content.present?
  end
end
