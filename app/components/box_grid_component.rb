# frozen_string_literal: true

class BoxGridComponent < ViewComponent::Base
  attr_reader :columns_count

  def initialize(columns: 2)
    @columns_count = columns
  end

  def grid_class
    case columns_count
    when 3 then "grid-cols-3"
    else "grid-cols-2"
    end
  end
end
