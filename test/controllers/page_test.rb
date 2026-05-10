# frozen_string_literal: true

require "test_helper"

class PageTest < ActionDispatch::IntegrationTest
  test "GET /impressum returns http success" do
    get imprint_path
    assert_response :success
  end
end
