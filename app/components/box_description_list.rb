# frozen_string_literal: true

class BoxDescriptionList
  def add(label, content_class = "")
    BoxDescriptionListItemComponent.new(
      label:,
      content_class:
    )
  end
end
