# frozen_string_literal: true

require "test_helper"

class RequestImageComponentTest < ApplicationViewComponentTestCase
  setup do
    @user = create(:user)
  end

  test "without an attached image, renders" do
    word = create(:noun)

    html = render_inline(RequestImageComponent.new(word: word, user: @user)).to_html

    assert_includes html, I18n.t("request_image_component.request")
  end

  test "without an attached image, with an existing image request, does not render" do
    word = create(:noun)
    create(:image_request, user: @user, word: word)

    html = render_inline(RequestImageComponent.new(word: word, user: @user)).to_html

    assert_empty html
  end

  test "without an attached image, without a user, does not render" do
    word = create(:noun)

    html = render_inline(RequestImageComponent.new(word: word, user: nil)).to_html

    assert_empty html
  end

  test "with an attached image, does not render" do
    word = create(:noun)
    word.image.attach(filename: "word.png", io: StringIO.new(file_fixture("avatar1.png").read))

    html = render_inline(RequestImageComponent.new(word: word, user: @user)).to_html

    assert_empty html
  end
end
