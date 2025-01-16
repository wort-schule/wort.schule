# frozen_string_literal: true

class WordImagesController < ApplicationController
  authorize_resource :word_images, class: false

  def index
    @word_images = Word
      .ordered_lexigraphically
      .joins(image_attachment: :blob)
      .pluck(
        :id,
        :name,
        ActiveStorage::Blob.arel_table[:filename]
      )
  end
end
