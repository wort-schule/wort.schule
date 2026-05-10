# frozen_string_literal: true

require "application_system_test_case"

class NounsCrudTest < ApplicationSystemTestCase
  extend CrudTests

  crud_tests_for Noun
end

class NounsTtsTest < ApplicationSystemTestCase
  extend TtsTests

  tts_tests_for Noun
end

class NounsTest < ApplicationSystemTestCase
  test "matches word case insensitive" do
    create(:noun, name: "Adler")

    visit "/Adler"
    assert_current_path "/adler"
    assert_selector "h1", text: "Adler"

    visit "/adler"
    assert_current_path "/adler"
    assert_selector "h1", text: "Adler"

    visit "/AdLEr"
    assert_current_path "/adler"
    assert_selector "h1", text: "Adler"
  end

  test "does not redirect routes below the scope 'seite'" do
    create(:noun, name: "Adler")

    visit "/seite/IMPRESSUM"
    assert_text "Routing Error"
    assert_current_path "/seite/IMPRESSUM"

    visit "/seite/impressum"
    assert_current_path "/seite/impressum"

    visit "/seite/NoUNs"
    assert_text "Routing Error"
    assert_current_path "/seite/NoUNs"
  end

  test "distinguishes between the word 'Seite' and the scope" do
    create(:noun, name: "Seite")

    visit "/seite"
    assert_current_path "/seite"
    assert_selector "h1", text: "Seite"

    visit "/seite/nouns"
    assert_current_path "/seite/nouns"
    assert_selector "h1", text: Noun.model_name.human(count: 2)
  end

  test "does not show change history when logged in as a lecturer" do
    word = create(:noun, name: "Buche")
    lecturer = create(:lecturer)
    login_as lecturer
    visit noun_path(word)

    assert_no_text t("words.versions.title")
  end

  test "shows change history when logged in as an admin" do
    word = create(:noun, name: "Buche")
    admin = create(:user, role: "Admin")
    login_as admin
    visit noun_path(word)

    assert_text t("shared.versions.title")
  end

  test "does not show another meaning with a unique word" do
    noun = create(:noun, name: "Ticken")
    more_meanings = I18n.t("words.show.more_meanings")

    visit noun_path(noun)

    assert_no_text more_meanings
  end

  test "shows another meaning with same spelling" do
    noun = create(:noun, name: "Ticken")
    create(:noun, name: "ticken")
    more_meanings = I18n.t("words.show.more_meanings")

    visit noun_path(noun)

    assert_text more_meanings
  end

  test "updates the hit counter" do
    noun = create(:noun, name: "Ticken")
    user = create(:guest)

    assert_equal 0, noun.hit_counter
    assert_equal 1, noun.versions.count

    visit noun_path(noun)
    assert_equal 1, noun.reload.hit_counter

    visit noun_path(noun)
    assert_equal 1, noun.reload.hit_counter

    Capybara.reset_sessions!

    login_as user
    visit noun_path(noun)
    assert_equal 2, noun.reload.hit_counter

    visit noun_path(noun)
    assert_equal 2, noun.reload.hit_counter

    logout
    visit noun_path(noun)
    assert_equal 3, noun.reload.hit_counter

    assert_equal 1, noun.versions.count
  end

  test "ignores hits from bots" do
    noun = create(:noun, name: "Ticken")

    page.driver.headers = {"User-Agent" => "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"}
    assert_equal 0, noun.reload.hit_counter
    visit noun_path(noun)
    assert_equal 0, noun.reload.hit_counter

    page.driver.headers = {"User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"}
    assert_equal 0, noun.reload.hit_counter
    visit noun_path(noun)
    assert_equal 1, noun.reload.hit_counter
  end
end
