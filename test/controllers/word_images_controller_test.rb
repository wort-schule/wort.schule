# frozen_string_literal: true

require "test_helper"

class WordImagesControllerTest < ActionDispatch::IntegrationTest
  test "without words is empty" do
    get word_images_path

    assert_includes response.body, I18n.t("word_images.index.empty")
  end

  test "with words shows only words with images" do
    word_without_image = create(:noun, name: "Katze")
    word_with_image = create(:adjective, name: "schön")
    filename = "word.png"

    word_with_image.image.attach(
      filename: filename,
      io: StringIO.new(file_fixture("avatar1.png").read)
    )

    get word_images_path

    assert_includes response.body, word_with_image.name
    assert_includes response.body, filename
    refute_includes response.body, word_without_image.name
  end
end
