# frozen_string_literal: true

class BoxGridComponent < ViewComponent::Base
  attr_reader :columns_count

  def initialize(columns: 2)
    @columns_count = columns
  end

  def grid_class
    case columns_count
    when 1 then ""
    when 2 then "cols-2 grid-cols-2"
    when 3 then "cols-3 grid-cols-2 lg:grid-cols-3"
    when 4 then "cols-4 grid-cols-2 lg:grid-cols-4"
    else ""
    end
  end
end
