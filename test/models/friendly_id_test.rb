# frozen_string_literal: true

require "test_helper"

class FriendlyIdTest < ActiveSupport::TestCase
  test "creates URLs without controller" do
    Rails.application.routes.default_url_options = {host: "example.com"}
    noun = create(:noun, name: "Bauer")
    assert_equal "http://example.com/bauer", Rails.application.routes.url_helpers.url_for(noun)
  end

  test "creates a slug" do
    noun = create(:noun, name: "Bauer")
    assert_equal "bauer", noun.slug
    assert_equal noun, Noun.find("bauer")
  end

  test "adds the topic to further slugs when multiple equal slugs exist" do
    noun1 = create(:noun, name: "Bauer")
    noun2 = create(:noun, name: "Bauer")
    noun3 = create(:noun, name: "Bauer")

    assert_equal "bauer", noun1.slug
    assert_equal "bauer-2", noun2.slug
    assert_equal "bauer-3", noun3.slug
  end

  test "lowercases the slug on update" do
    noun = create(:noun, name: "Bauer")
    assert_equal "bauer", noun.slug

    noun.update!(slug: "ADLer")

    assert_equal "adler", noun.slug
  end
end
