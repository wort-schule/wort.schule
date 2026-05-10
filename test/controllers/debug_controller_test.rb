# frozen_string_literal: true

require "test_helper"

class DebugControllerTest < ActionDispatch::IntegrationTest
  test "GET /debug when user is not authenticated redirects to login" do
    get "/debug"
    assert_redirected_to(/devise\/users\/sign_in/)
  end

  test "GET /debug when user is not an admin redirects to root_path" do
    user = create(:user)
    sign_in user

    get "/debug"
    assert_redirected_to root_path
  end

  test "GET /debug when user is not an admin shows alert message" do
    user = create(:user)
    sign_in user

    get "/debug"
    assert_equal "Unauthorized", flash[:alert]
  end

  test "GET /debug when user is an admin returns http success" do
    sign_in create(:admin)

    get "/debug"
    assert_response :success
  end

  test "GET /debug when user is an admin displays LLM service status" do
    sign_in create(:admin)
    create(:llm_service, api_key: "test-key", active: true)

    get "/debug"
    assert_includes response.body, "LLM Service Status"
  end

  test "GET /debug when user is an admin displays queue statistics" do
    sign_in create(:admin)

    get "/debug"
    assert_includes response.body, "Queue Statistics"
    assert_includes response.body, "Pending Jobs"
  end

  test "GET /debug when user is an admin displays LLM invocations section" do
    sign_in create(:admin)

    get "/debug"
    assert_includes response.body, "Recent LLM Invocations"
  end

  test "GET /debug when user is an admin displays word imports section" do
    sign_in create(:admin)

    get "/debug"
    assert_includes response.body, "Recent Word Imports"
  end

  test "GET /debug when user is an admin displays help section" do
    sign_in create(:admin)

    get "/debug"
    assert_includes response.body, "How to Debug LLM Issues"
  end

  test "GET /debug when user is an admin displays system information with Ruby version" do
    sign_in create(:admin)

    get "/debug"
    assert_includes response.body, "System Information"
    assert_includes response.body, "Ruby Version"
    assert_includes response.body, RUBY_VERSION
  end

  test "GET /debug with LLM invocations displays word identifier as clickable link for word enrichment" do
    sign_in create(:admin)
    word = create(:noun, name: "Haus")
    create(:word_llm_invocation,
      key: "Noun##{word.id}",
      invocation_type: "enrichment",
      state: "completed")

    get "/debug"
    assert_includes response.body, polymorphic_path(word)
    assert_includes response.body, "Noun##{word.id}"
    assert_includes response.body, word.name
  end

  test "GET /debug with LLM invocations displays word information for check_base_form invocations" do
    sign_in create(:admin)
    create(:word_llm_invocation,
      key: "Hund#Animals#Noun",
      invocation_type: "check_base_form",
      state: "completed")

    get "/debug"
    assert_includes response.body, "Hund"
    assert_includes response.body, "Animals"
  end

  test "GET /debug with word imports displays word import information with name and topic" do
    sign_in create(:admin)
    create(:word_import,
      name: "Katze",
      topic: "Pets",
      word_type: "Noun",
      state: "completed")

    get "/debug"
    assert_includes response.body, "Katze"
    assert_includes response.body, "Pets"
  end

  test "GET /debug with failed LLM invocations displays full error button" do
    sign_in create(:admin)
    error_message = "Faraday::BadRequestError: the server responded with status 400\n/path/to/file.rb:123"
    create(:word_llm_invocation,
      key: "Noun#123",
      invocation_type: "enrichment",
      state: "failed",
      error: error_message)

    get "/debug"
    assert_includes response.body, "Show full error"
  end

  test "GET /debug with failed LLM invocations displays separate JSON API Error column when JSON is present" do
    sign_in create(:admin)
    error_with_json = <<~ERROR
      Faraday::BadRequestError: the server responded with status 400
      {"error":{"message":"Invalid request","type":"invalid_request_error","code":"invalid_value"}}
    ERROR
    create(:word_llm_invocation,
      key: "Noun#456",
      invocation_type: "enrichment",
      state: "failed",
      error: error_with_json)

    get "/debug"
    assert_includes response.body, "JSON API Error"
    assert_includes response.body, "Show JSON"
  end

  test "GET /debug with failed LLM invocations extracts JSON from API Response Body section" do
    sign_in create(:admin)
    error_with_api_response = <<~ERROR
      Faraday::BadRequestError: the server responded with status 400
      /path/to/file.rb:30:in 'on_complete'

      API Response Body:
      {"error":{"message":"Invalid API key","type":"invalid_request_error","code":"invalid_api_key"}}
    ERROR
    create(:word_llm_invocation,
      key: "Noun#999",
      invocation_type: "enrichment",
      state: "failed",
      error: error_with_api_response)

    get "/debug"
    assert_includes response.body, "JSON API Error"
    assert_includes response.body, "Show JSON"
  end

  test "GET /debug with failed LLM invocations shows dash when no JSON API error is present" do
    sign_in create(:admin)
    error_without_json = "Some error without JSON"
    create(:word_llm_invocation,
      key: "Noun#789",
      invocation_type: "enrichment",
      state: "failed",
      error: error_without_json)

    get "/debug"
    assert_includes response.body, "JSON API Error"
  end
end
