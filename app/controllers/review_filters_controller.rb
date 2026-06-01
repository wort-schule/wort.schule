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
    canonical_key = attribute_keys[attribute_name]
    return unless canonical_key # ignore unknown types

    attributes = if current_user.review_attributes_without_types.include?(attribute_name)
      current_user.review_attributes.reject { |key| key.split(".").last == attribute_name }
    else
      current_user.review_attributes + [canonical_key]
    end

    current_user.update!(review_attributes: attributes)
  end

  # Maps a bare attribute_name (e.g. "keywords") to its canonical
  # "type.attribute" profile key (e.g. "noun.keywords"). Also acts as the
  # allow-list: unknown attribute names map to nil and are ignored.
  def attribute_keys
    Llm::Attributes.collection.each_with_object({}) do |(_title, key), map|
      map[key.split(".").last] ||= key
    end
  end
end
