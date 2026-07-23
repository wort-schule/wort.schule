# frozen_string_literal: true

require "test_helper"

class WordHeaderComponentTest < ApplicationViewComponentTestCase
  # The template asks for the current word view settings, which go through
  # Devise's current_user. Point Devise at ViewComponent's test controller
  # before its own setup runs, so the helper resolves to a signed-out visitor
  # instead of raising Devise::MissingWarden.
  setup do
    @controller = vc_test_controller
    @request = vc_test_controller.request
  end

  include Devise::Test::ControllerHelpers

  test "renders the stored alt text for the word image" do
    word = word_with_image(image_alt_text: "Ein brauner Hund rennt über eine Wiese.")

    render_inline(WordHeaderComponent.new(word: word, word_font: nil))

    assert_selector "img[alt='Ein brauner Hund rennt über eine Wiese.']"
  end

  test "falls back to a generic alt text when none is stored" do
    word = word_with_image(image_alt_text: nil)

    render_inline(WordHeaderComponent.new(word: word, word_font: nil))

    assert_selector "img[alt='#{I18n.t("word_header_component.image_fallback_alt", name: word.name)}']"
  end

  test "falls back to a generic alt text when the stored one is blank" do
    word = word_with_image(image_alt_text: "   ")

    render_inline(WordHeaderComponent.new(word: word, word_font: nil))

    assert_selector "img[alt='#{I18n.t("word_header_component.image_fallback_alt", name: word.name)}']"
  end

  # An img without any alt attribute makes screen readers read out the file name,
  # which is worse than an empty alt. Decorative images in the header (word type
  # and strategy symbols) therefore need alt="" rather than nothing (WCAG 1.1.1).
  test "renders no image at all without an alt attribute" do
    word = word_with_image(image_alt_text: nil)
    strategy = create(:strategy)
    strategy.fresch_symbol.attach(filename: "fresch.png", io: StringIO.new(file_fixture("avatar1.png").read))
    word.strategies << strategy

    render_inline(WordHeaderComponent.new(word: word, word_font: nil))

    assert_no_selector "img:not([alt])"
  end

  private

  def word_with_image(image_alt_text:)
    word = create(:noun, name: "Hund", image_alt_text: image_alt_text)
    word.image.attach(filename: "hund.png", io: StringIO.new(file_fixture("avatar1.png").read))
    word
  end
end
