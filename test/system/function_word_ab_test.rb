# frozen_string_literal: true

require "application_system_test_case"

class FunctionWordAbTest < ApplicationSystemTestCase
  setup do
    @function_word = create(:function_word, name: "ab", slug: "ab", function_type: "preposition")
  end

  test "loads the /ab page successfully when logged in" do
    user = create(:user)
    login_as(user, scope: :user)

    visit "/ab"
    assert_text "ab"
    assert_selector "h1", text: /ab/i
  end

  test "shows the function word details when logged in" do
    user = create(:user)
    login_as(user, scope: :user)

    visit "/ab"
    assert_text "Präposition"
  end

  test "loads the /ab page successfully when not logged in" do
    visit "/ab"
    assert_text "ab"
    assert_selector "h1", text: /ab/i
  end

  test "shows the function word details when not logged in" do
    visit "/ab"
    assert_text "Präposition"
  end
end
