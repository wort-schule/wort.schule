# frozen_string_literal: true

require "test_helper"

class CompoundVocalalternationsControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundVocalalternation,
    valid_attrs: {name: "u→ü"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "e→i"}
  )
end
