# frozen_string_literal: true

require "application_system_test_case"

class VerbsCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for Verb
end

class VerbsTtsTest < ApplicationSystemTestCase
  extend TtsTests

  tts_tests_for Verb
end
