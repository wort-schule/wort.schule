# frozen_string_literal: true

class ReviewFiltersController < ApplicationController
  authorize_resource :review, class: false

  def update
    review_type = params[:review_type].to_s

    if review_type == "new_word"
      current_user.update!(review_new_words: !current_user.review_new_words?)
    else
      toggle_attribute(review_type)
    end

    redirect_to reviews_path
  end

  private

  def toggle_attribute(attribute_name)
    canonical_key = Llm::Attributes.by_attribute_name.dig(attribute_name, :key)
    return unless canonical_key # ignore unknown types

    attributes = if current_user.review_attributes_without_types.include?(attribute_name)
      current_user.review_attributes.reject { |key| Llm::Attributes.bare_name(key) == attribute_name }
    else
      current_user.review_attributes + [canonical_key]
    end

    current_user.update!(review_attributes: attributes)
  end
end
