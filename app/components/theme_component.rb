# frozen_string_literal: true

class ThemeComponent < ViewComponent::Base
  include WordHelper

  attr_reader :word, :preview

  def initialize(word:, theme:)
    @word = word
    @theme = theme
    @default = theme.blank?
    @preview = !word.persisted?
  end

  def before_render
    @word_image_url = url_for @word.image if @word.image.attached?
  end

  def liquid_template
    template = @default ? Theme.default_template(word_type:) : @theme.template
    template_renderer = Liquid::Template.parse(sanitize_template(template))

    template_renderer.render(params.with_indifferent_access.merge(view_context:)).html_safe
  end

  private

  def sanitize_template(template)
    Sanitize.fragment template, sanitize_config
  end

  def sanitize_config
    Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements: Sanitize::Config::RELAXED[:elements] + %w[audio svg],
      remove_contents: %w[iframe math noembed noframes noscript plaintext script xmp],
      transformers: [
        lambda do |env|
          node = env[:node]
          node_name = env[:node_name]

          {node_allowlist: [node, node.children].flatten} if node_name == "svg"
        end,
        lambda do |env|
          node = env[:node]
          node_name = env[:node_name]

          allowed = node_name == "audio" && node["src"].start_with?("/rails/active_storage/")

          {node_allowlist: [node, node.children].flatten} if allowed
        end
      ]
    )
  end

  def word_type
    @word.model_name.singular.underscore
  end

  def params
    ThemeVariables.public_send(:"#{word_type}_variables", @word, @word_image_url, view_context)
  end
end
