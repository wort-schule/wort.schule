# frozen_string_literal: true

require "application_system_test_case"

class SpecialEntriesCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for FunctionWord
  crud_tests_for Topic
  crud_tests_for Hierarchy
  crud_tests_for Prefix
  crud_tests_for Postfix
  crud_tests_for Phenomenon
  crud_tests_for Strategy
  crud_tests_for CompoundInterfix
  crud_tests_for CompoundPreconfix
  crud_tests_for CompoundPostconfix
  crud_tests_for CompoundPhonemReduction
  crud_tests_for CompoundVocalalternation
end
