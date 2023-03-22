# frozen_string_literal: true

class BoxGridComponent < ViewComponent::Base
  attr_reader :columns_count

  def initialize(columns: 2)
    @columns_count = columns
  end

  def grid_class
    case columns_count
    when 1 then ""
    when 2 then "grid-cols-2"
    when 3 then "grid-cols-3"
    else ""
    end
  end
end
