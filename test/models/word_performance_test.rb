# frozen_string_literal: true

require "test_helper"

class WordPerformanceTest < ActiveSupport::TestCase
  test "consonant_vowel attribute sets pattern on save" do
    word = create(:noun, name: "Hund")
    assert_equal "KVKK", word.consonant_vowel
  end

  test "#hit! increments hit counter" do
    word = create(:noun, hit_counter: 5)
    session = {}
    user_agent = "Mozilla/5.0"

    assert_difference -> { word.reload.hit_counter }, 1 do
      word.hit!(session, user_agent)
    end
  end
end
