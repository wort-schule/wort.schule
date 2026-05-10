# frozen_string_literal: true

require "application_system_test_case"

class SourcesCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for Source
end
