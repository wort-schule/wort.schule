# frozen_string_literal: true

class Box < Liquid::Block
  attr_reader :title

  def initialize(tag_name, title, options)
    super
    @title = title
  end

  def render(context)
    view_context = context.environments.first["view_context"]

    BoxComponent.new(title:)
      .with_content(super.html_safe)
      .render_in(view_context)
  end
end
