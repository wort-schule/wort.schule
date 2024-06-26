# frozen_string_literal: true

module OpenGraph
  extend ActiveSupport::Concern

  def set_open_graph_tags
    return unless resource&.is_a?(Word)

    set_meta_tags(
      og: {
        title: resource.name,
        description: resource.meaning_long,
        url: url_for(resource),
        image: resource.image.attached? ? url_for(resource.image.variant(:open_graph)) : nil
      },
      twitter: resource.image.attached? ? {
        card: "summary_large_image",
        title: resource.name,
        image: {
          _: url_for(resource.image.variant(:open_graph)),
          width: 1200,
          height: 630
        }
      } : nil
    )
  end

  def resource
    resource_name = params[:controller].singularize
    return if %w[noun verb adjective].exclude?(resource_name)

    instance_variable_get :"@#{resource_name}"
  end
end
