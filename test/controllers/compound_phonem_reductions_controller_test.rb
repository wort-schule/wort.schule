# frozen_string_literal: true

require "test_helper"

class CompoundPhonemReductionsControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundPhonemReduction,
    valid_attrs: {name: "i→ø"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "o→ø"}
  )
end
