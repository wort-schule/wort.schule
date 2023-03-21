# frozen_string_literal: true

class LabeledValueComponent < ViewComponent::Base
  attr_reader :label, :value

  def initialize(label:, value:)
    @label = label
    @value = value
  end

  def render?
    label.present? && value.present?
  end
end
