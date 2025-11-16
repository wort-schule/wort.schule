# frozen_string_literal: true

# Provides standard image attachment configuration with thumb and open graph variants.
# Used by models that need image attachments with consistent sizing.
module HasStandardImage
  extend ActiveSupport::Concern

  included do
    has_one_attached :image do |attachable|
      attachable.variant :thumb, resize_to_fill: [100, 100], format: :png
      attachable.variant :open_graph, resize_to_fill: [1200, 630], format: :png
    end
  end
end
