# frozen_string_literal: true

require "application_system_test_case"

class ImageRequestsTest < ApplicationSystemTestCase
  setup do
    @noun = create(:noun, meaning: "Meaning of the word")
    @user = create(:admin)
    @request_button = I18n.t("request_image_component.request")
    login_as @user
  end

  test "creates an image request" do
    visit noun_path(@noun)

    assert_difference -> { ImageRequest.count }, +1 do
      click_on @request_button
    end

    last_request = ImageRequest.last
    assert_equal @noun, last_request.word
    assert_equal @user, last_request.user

    assert_no_text @request_button
  end

  test "lists requests with existing requests" do
    create(:image_request, word: @noun, user: @user)
    create(:image_request, word: @noun, user: create(:user))
    create(:image_request, word: @noun, user: create(:user))

    visit image_requests_path

    assert_text @noun.name
    assert_text @noun.meaning
    assert_text 3
  end

  test "removes the requests when image is attached" do
    create(:image_request, word: @noun, user: @user)
    create(:image_request, word: @noun, user: create(:user))
    create(:image_request, word: @noun, user: create(:user))

    assert_difference -> { ImageRequest.count }, -3 do
      @noun.image.attach(filename: "word.png", io: StringIO.new(file_fixture("avatar1.png").read))
    end

    visit image_requests_path
    assert_text I18n.t("image_requests.index.empty")
  end
end
