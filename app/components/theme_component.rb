# frozen_string_literal: true

class ThemeComponent < ViewComponent::Base
  include WordHelper

  def initialize(word:, theme:, default:)
    @word = word
    @theme = theme
    @default = default
  end

  def before_render
    @word_image_url = url_for @word.image if @word.image.attached?
  end

  def liquid_template
    template = @default ? File.read(Rails.root.join("app/views/themes/default_#{word_type}.liquid")) : @theme.template
    template_renderer = Liquid::Template.parse(template)
    template_renderer.render(params.with_indifferent_access).html_safe
  end

  private

  def word_type
    @word.model_name.singular.underscore
  end

  def params
    case @word
    when Noun then ThemeVariables.noun_variables(@word, @word_image_url)
    when Verb then ThemeVariables.verb_variables(@word, @word_image_url)
    when Adjective then ThemeVariables.adjective_variables(@word, @word_image_url)
    end
  end
end
