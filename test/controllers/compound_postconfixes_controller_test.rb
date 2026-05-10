# frozen_string_literal: true

require "test_helper"

class CompoundPostconfixesControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundPostconfix,
    valid_attrs: {name: "-keit"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "-ung"}
  )
end
