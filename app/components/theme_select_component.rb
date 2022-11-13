# frozen_string_literal: true

class ThemeSelectComponent < ViewComponent::Base
  include ComponentsHelper

  attr_reader :active, :word_type

  def initialize(theme:, active:, word_type:)
    @theme = theme
    @active = active
    @word_type = word_type
  end

  def theme
    return @theme if @theme.present?

    Theme.new(
      id: 0,
      name: I18n.t("themes.show.standard")
    )
  end

  def box_classes
    classes = "h-full flex flex-col gap-6"

    return classes unless active

    "#{classes} border-2 border-indigo-600 shadow-lg"
  end
end
