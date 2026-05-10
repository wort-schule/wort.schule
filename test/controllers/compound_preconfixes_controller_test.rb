# frozen_string_literal: true

require "test_helper"

class CompoundPreconfixesControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundPreconfix,
    valid_attrs: {name: "ver-"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "ent-"}
  )
end
