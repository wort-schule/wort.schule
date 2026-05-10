# frozen_string_literal: true

require "test_helper"

class NounsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin)
    @word = create(:noun)
    @compound_preconfix = create(:compound_preconfix)
    @compound_postconfix = create(:compound_postconfix)

    sign_in @admin
  end

  test "#create assigns compound entities" do
    post nouns_path, params: {
      noun: {
        name: "Compound Test",
        compound_entity_ids: [
          "Word:#{@word.id}",
          "CompoundPreconfix:#{@compound_preconfix.id}",
          "CompoundPostconfix:#{@compound_postconfix.id}"
        ]
      }
    }

    noun = Noun.last
    assert_equal "Compound Test", noun.name

    entities = noun
      .compound_entities
      .order(:pos)
      .pluck(:word_id, :part_id, :part_type, :pos)

    assert_equal [
      [noun.id, @word.id, "Word", 1],
      [noun.id, @compound_preconfix.id, "CompoundPreconfix", 2],
      [noun.id, @compound_postconfix.id, "CompoundPostconfix", 3]
    ], entities
  end

  test "#update removes a compound entity" do
    noun = create(:noun)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @word, pos: 1)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @compound_preconfix, pos: 2)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @compound_postconfix, pos: 3)

    patch noun_path(noun), params: {
      noun: {
        compound_entity_ids: [
          "Word:#{@word.id}",
          "CompoundPostconfix:#{@compound_postconfix.id}"
        ]
      }
    }

    noun.reload

    entities = noun
      .compound_entities
      .order(:pos)
      .pluck(:word_id, :part_id, :part_type, :pos)

    assert_equal [
      [noun.id, @word.id, "Word", 1],
      [noun.id, @compound_postconfix.id, "CompoundPostconfix", 2]
    ], entities
  end

  test "#update allows IDs of compound entities to be sent" do
    noun = create(:noun)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @word, pos: 1)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @compound_preconfix, pos: 2)
    noun.compound_entities << CompoundEntity.create(word: noun, part: @compound_postconfix, pos: 3)

    patch noun_path(noun), params: {
      noun: {
        compound_entity_ids: [
          noun.compound_entities.first.id.to_s,
          noun.compound_entities.third.id.to_s
        ]
      }
    }

    noun.reload

    entities = noun
      .compound_entities
      .order(:pos)
      .pluck(:word_id, :part_id, :part_type, :pos)

    assert_equal [
      [noun.id, @word.id, "Word", 1],
      [noun.id, @compound_postconfix.id, "CompoundPostconfix", 2]
    ], entities
  end

  test "images load correctly" do
    @word.image.attach(
      io: StringIO.new(File.read(Rails.root.join("test/fixtures/files/avatar1.png"))),
      filename: "example.png"
    )

    ActiveStorage::Current.url_options = {host: "localhost"}

    assert @word.image.attached?

    get @word.image.url
    assert_response :success
  end

  test "JSON response includes full URL with host for image_url" do
    @word.image.attach(
      io: StringIO.new(File.read(Rails.root.join("test/fixtures/files/avatar1.png"))),
      filename: "example.png"
    )

    Rails.application.routes.default_url_options = {host: "example.com", protocol: "https"}
    ActiveStorage::Current.url_options = {host: "example.com", protocol: "https"}

    get noun_path(@word, format: :json)

    assert_response :success
    json_response = JSON.parse(response.body)

    assert json_response["image_url"].present?
    assert_includes json_response["image_url"], "example.com"
    assert_includes json_response["image_url"], "/rails/active_storage/blobs/"
    refute_includes json_response["image_url"], "/redirect/"
    assert_no_match(/[?&]exp=/, json_response["image_url"])
  end
end
