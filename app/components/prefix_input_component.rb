# frozen_string_literal: true

class PrefixInputComponent < ViewComponent::Base
  def initialize(prefix:, hint: "", width_class: "w-14")
    @prefix = prefix
    @hint = hint
    @width_class = width_class
  end
end
