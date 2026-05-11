# frozen_string_literal: true

require "test_helper"

class Forms::BulkEditSearchTest < ActiveSupport::TestCase
  test "anchors the wildcard pattern with ^ at the start" do
    haustier = create(:noun, name: "Haustier")
    hausboot = create(:noun, name: "Hausboot")
    create(:noun, name: "Schule")

    names = Forms::BulkEditSearch.new(q: "^Haus*").results.pluck(:name)
    assert_equal [hausboot.name, haustier.name].sort, names.sort
  end

  test "anchors the wildcard pattern with $ at the end" do
    create(:noun, name: "Haus")
    lehrung = create(:noun, name: "Lehrung")

    names = Forms::BulkEditSearch.new(q: "*ung$").results.pluck(:name)
    assert_equal [lehrung.name], names
  end

  test "matches exactly with ^...$" do
    schule = create(:noun, name: "Schule")
    create(:noun, name: "Schulen")

    names = Forms::BulkEditSearch.new(q: "^Schule$").results.pluck(:name)
    assert_equal [schule.name], names
  end

  test "filters by word_type when given" do
    create(:noun, name: "Haus")
    verb = create(:verb, name: "gehen")

    results = Forms::BulkEditSearch.new(q: "*e*", word_type: "Verb").results.to_a
    assert_includes results, verb
  end

  test "falls back to the name field when an unknown search_field is given" do
    create(:noun, name: "Haus")
    assert_nothing_raised { Forms::BulkEditSearch.new(q: "Haus", search_field: "secret").results.load }
  end

  test "missing_field filter returns only words without that HABTM association" do
    with_p = create(:noun, name: "Mit")
    with_p.phenomenons << create(:phenomenon, name: "P")
    without_p = create(:noun, name: "Ohne")

    results = Forms::BulkEditSearch.new(missing_field: "phenomenons").results.to_a
    assert_includes results, without_p
    refute_includes results, with_p
  end

  test "ignores an unknown missing_field" do
    assert_nothing_raised { Forms::BulkEditSearch.new(missing_field: "junk").results.load }
  end

  test "#queried? returns true when q or missing_field is set" do
    assert Forms::BulkEditSearch.new(q: "x").queried?
    assert Forms::BulkEditSearch.new(missing_field: "phenomenons").queried?
    refute Forms::BulkEditSearch.new({}).queried?
  end
end
