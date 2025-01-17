class CreateRequestedWordImages < ActiveRecord::Migration[7.1]
  def change
    create_view :requested_word_images
  end
end
