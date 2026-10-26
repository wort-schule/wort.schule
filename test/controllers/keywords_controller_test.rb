# frozen_string_literal: true

require "test_helper"

class KeywordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tier = create(:noun, name: "Tier")
    @haustier = create(:noun, name: "Haustier")
    create(:noun, name: "Hund").keywords << [@tier, @haustier]
  end

  test "GET /seite/keyword shows the related keywords with their word counts" do
    get keyword_path(keyword_ids: @tier.id.to_s)

    assert_response :success
    assert_includes response.body, "Haustier"
  end

  test "GET /seite/keyword ignores text after the ids instead of answering with 500" do
    get keyword_path(keyword_ids: "#{@tier.id} möchte ich folgenden Fehler melden:")

    assert_response :success
    assert_includes response.body, "Haustier"
  end
end
