# frozen_string_literal: true

require "test_helper"

class Llm::InvokeTest < ActiveSupport::TestCase
  def build_invoke(model)
    Llm::Invoke.new(
      prompt: "Test prompt",
      prompt_variables: {word: "Test"},
      response_model: Llm::Schema::Keywords,
      model: model
    )
  end

  def build_invoke_with_default_model
    Llm::Invoke.new(
      prompt: "Test prompt",
      prompt_variables: {word: "Test"},
      response_model: Llm::Schema::Keywords
    )
  end

  test "#model defaults to the active LlmService's model" do
    create(:llm_service, model: "llama3.1")
    assert_equal "llama3.1", build_invoke_with_default_model.model
  end

  test "building without a model does not raise when no LlmService is active" do
    # Issue #752: with no active LLM service, default_model called .model on
    # nil and crashed the (function word) detail pages that build an Invoke.
    assert_nil LlmService.active
    assert_nil build_invoke_with_default_model.model
  end

  test "#gpt5_model? returns false for gpt-4" do
    assert_equal false, build_invoke("gpt-4").send(:gpt5_model?)
  end

  test "#gpt5_model? returns false for gpt-4.1" do
    assert_equal false, build_invoke("gpt-4.1").send(:gpt5_model?)
  end

  test "#gpt5_model? returns true for gpt-5" do
    assert_equal true, build_invoke("gpt-5").send(:gpt5_model?)
  end

  test "#gpt5_model? returns true for gpt-5-mini" do
    assert_equal true, build_invoke("gpt-5-mini").send(:gpt5_model?)
  end

  test "#gpt5_model? returns true for gpt-5-nano" do
    assert_equal true, build_invoke("gpt-5-nano").send(:gpt5_model?)
  end

  test "#gpt5_model? returns true for GPT-5-MINI (uppercase)" do
    assert_equal true, build_invoke("GPT-5-MINI").send(:gpt5_model?)
  end

  test "#client_options with GPT-4 includes temperature parameter" do
    options = build_invoke("gpt-4").send(:client_options)
    assert_includes options.to_a, [:temperature, 0.0]
    assert_includes options.to_a, [:chat_model, "gpt-4"]
  end

  test "#client_options with GPT-5-mini excludes temperature parameter" do
    options = build_invoke("gpt-5-mini").send(:client_options)
    refute options.key?(:temperature)
    assert_includes options.to_a, [:chat_model, "gpt-5-mini"]
  end

  test "#client_options with GPT-5-nano excludes temperature parameter" do
    options = build_invoke("gpt-5-nano").send(:client_options)
    refute options.key?(:temperature)
    assert_includes options.to_a, [:chat_model, "gpt-5-nano"]
  end
end
