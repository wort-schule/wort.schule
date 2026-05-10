# frozen_string_literal: true

require "test_helper"

class CompoundInterfixesControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundInterfix,
    valid_attrs: {name: "-en-"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "-er-"}
  )
end
