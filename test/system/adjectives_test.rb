# frozen_string_literal: true

require "application_system_test_case"

class AdjectivesCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for Adjective
end

class AdjectivesTtsTest < ApplicationSystemTestCase
  extend TtsTests

  tts_tests_for Adjective
end
