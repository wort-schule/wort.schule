# frozen_string_literal: true

require "test_helper"

class PageTest < ActionDispatch::IntegrationTest
  test "GET /impressum returns http success" do
    get imprint_path
    assert_response :success
  end

  test "imprint links bug reports to the GitHub bug report form" do
    get imprint_path

    assert_select "a[href=?]",
      "https://github.com/wort-schule/wort.schule/issues/new?template=bug_report.yml",
      text: "Falls Ihnen Fehler auffallen, melden Sie diese bitte online."
  end
end
