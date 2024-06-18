# frozen_string_literal: true

class BoxDescriptionList
  def add(label, content_class = "", hide_if_blank: true)
    BoxDescriptionListItemComponent.new(
      label:,
      content_class:,
      hide_if_blank:
    )
  end
end
