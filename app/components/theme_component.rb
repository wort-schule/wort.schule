# frozen_string_literal: true

class ThemeComponent < ViewComponent::Base
  include WordHelper

  def initialize(word:, theme:, default: false)
    @word = word
    @theme = theme
    @default = default
  end

  def before_render
    @word_image_url = url_for @word.image if @word.image.attached?
  end

  def liquid_template
    template = @default ? Theme.default_template(word_type:) : @theme.template
    template_renderer = Liquid::Template.parse(template)
    rendered = template_renderer.render(params.with_indifferent_access)

    sanitize_template(rendered).html_safe
  end

  private

  def sanitize_template(template)
    Sanitize.fragment template, Sanitize::Config::RELAXED
  end

  def word_type
    @word.model_name.singular.underscore
  end

  def params
    ThemeVariables.public_send("#{word_type}_variables", @word, @word_image_url)
  end
end
