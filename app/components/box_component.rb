# frozen_string_literal: true

class BoxComponent < ViewComponent::Base
  attr_reader :title

  def initialize(title:)
    @title = title
  end
end
