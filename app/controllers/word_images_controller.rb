# frozen_string_literal: true

class WordImagesController < PublicController
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

  private

  def page_title
    t("word_images.index.title")
  end
  helper_method :page_title
end
