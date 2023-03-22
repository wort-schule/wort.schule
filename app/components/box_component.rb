# frozen_string_literal: true

class BoxComponent < ViewComponent::Base
  attr_reader :title

  def initialize(title:, span: 1)
    @title = title
    @span = span
  end

  def span_class
    case @span
    when 1 then ""
    when 2 then "col-span-2"
    else ""
    end
  end
end
