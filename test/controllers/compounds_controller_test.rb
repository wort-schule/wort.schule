# frozen_string_literal: true

require "test_helper"

class CompoundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin)
    sign_in @admin

    @noun = create(:noun, name: "Bach")
    @noun_with_meaning = create(:noun, name: "Haus", meaning: "Gebäude")
    @compound_postconfix = create(:compound_postconfix, name: "-thek")
    @function_word = create(:function_word, name: "die")
  end

  test "GET #index without search query returns a limited set of words and compounds" do
    get compounds_path(format: :json)

    result = JSON.parse(response.body, symbolize_names: true)
    assert_includes result, {
      text: "Bach",
      value: "Word:#{@noun.id}"
    }
    assert_includes result, {
      text: "Haus [Gebäude]",
      value: "Word:#{@noun_with_meaning.id}"
    }
    assert_includes result, {
      text: "-thek [Postkonfix]",
      value: "CompoundPostconfix:#{@compound_postconfix.id}"
    }
    assert_includes result, {
      text: "die",
      value: "Word:#{@function_word.id}"
    }
  end

  test "GET #index with search query filters results by query" do
    get compounds_path(format: :json, q: "Haus")

    result = JSON.parse(response.body, symbolize_names: true)
    assert_includes result, {
      text: "Haus [Gebäude]",
      value: "Word:#{@noun_with_meaning.id}"
    }
    refute_includes result, {
      text: "Bach",
      value: "Word:#{@noun.id}"
    }
  end
end
