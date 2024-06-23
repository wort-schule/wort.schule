# frozen_string_literal: true

class BoxGrid < Liquid::Block
  attr_reader :columns

  def initialize(tag_name, columns, options)
    super
    @columns = columns.presence.to_i
    @columns = 2 unless @columns.positive?
  end

  def render(context)
    view_context = context.environments.first["view_context"]

    BoxGridComponent.new(columns:)
      .with_content(super.html_safe)
      .render_in(view_context)
  end
end
