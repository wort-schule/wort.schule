# frozen_string_literal: true

class BoxDescriptionListItemComponent < ViewComponent::Base
  def initialize(label:, content_class:, hide_if_blank: true)
    @label = label
    @content_class = content_class
    @hide_if_blank = hide_if_blank
  end

  def render?
    return true if !Rails.configuration.hide_blank_items || !@hide_if_blank

    content.present?
  end
end
