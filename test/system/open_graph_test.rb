# frozen_string_literal: true

require "application_system_test_case"

class OpenGraphTest < ApplicationSystemTestCase
  test "does not render open graph tags for non-word pages" do
    visit root_path

    assert_no_selector "meta[property='og:title']", visible: false
  end

  test "does not render open graph tags for index pages" do
    visit nouns_path

    assert_no_selector "meta[property='og:title']", visible: false
  end

  test "with a noun having only a name, adds a title tag" do
    noun = create(:noun, name: "Abend", meaning_long: nil)

    visit noun_path(noun)

    assert_open_graph "og:title", "Abend"
    assert_open_graph "og:url", %r{/abend\z}
    assert_no_selector "meta[property='og:description']", visible: false
    assert_no_selector "meta[property='og:image']", visible: false
  end

  test "with a noun with detailed information, adds multiple tags" do
    noun = create(:noun, name: "Abend", meaning_long: "Tageszeit um die Dämmerung, das Dunkelwerden vor Beginn der Nacht")
    noun.update!(
      image: ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(File.read(Rails.root.join("test/fixtures/files/avatar1.png").to_s)),
        filename: "avatar1.png"
      )
    )

    visit noun_path(noun)

    assert_open_graph "og:title", "Abend"
    assert_open_graph "og:description", "Tageszeit um die Dämmerung, das Dunkelwerden vor Beginn der Nacht"
    assert_open_graph "og:url", %r{/abend\z}
    assert_open_graph "og:image", %r{/rails/active_storage/.*/avatar1\.png\z}
  end
end
