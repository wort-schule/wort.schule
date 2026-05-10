# frozen_string_literal: true

require "test_helper"

class Llm::AttributesTest < ActiveSupport::TestCase
  test ".response_model returns the correct schema for Noun" do
    assert_equal Llm::Schema::Noun, Llm::Attributes.response_model("Noun")
  end

  test ".response_model returns the correct schema for Verb" do
    assert_equal Llm::Schema::Verb, Llm::Attributes.response_model("Verb")
  end

  test ".response_model returns the correct schema for Adjective" do
    assert_equal Llm::Schema::Adjective, Llm::Attributes.response_model("Adjective")
  end

  test ".response_model returns the correct schema for FunctionWord" do
    assert_equal Llm::Schema::FunctionWord, Llm::Attributes.response_model("FunctionWord")
  end

  test ".response_model raises an error for unsupported word types" do
    error = assert_raises(Llm::Attributes::UnsupportedWordType) do
      Llm::Attributes.response_model("InvalidType")
    end
    assert_equal "Word type 'InvalidType' is not supported for LLM enrichment", error.message
  end

  test ".filter returns matches irrelevant of capitalization" do
    noun = create(:noun, name: "Spielen")
    verb = create(:noun, name: "spielen")

    result = Llm::Attributes.filter(
      response_model: Llm::Schema::Keywords,
      attribute_name: "keywords",
      value: ["Spielen"]
    )

    assert_equal [noun.id.to_s, verb.id.to_s].sort, result.sort
  end

  test ".filter with case sensitive search returns only exact matches" do
    noun = create(:noun, name: "Spielen")
    create(:noun, name: "spielen")

    config = Rails.application.config
    original = config.reviews_keywords_search_case_insensitive
    config.reviews_keywords_search_case_insensitive = false
    begin
      result = Llm::Attributes.filter(
        response_model: Llm::Schema::Keywords,
        attribute_name: "keywords",
        value: ["Spielen"]
      )
      assert_equal [noun.id.to_s], result
    ensure
      config.reviews_keywords_search_case_insensitive = original
    end
  end
end
