# frozen_string_literal: true

require "test_helper"

class KeywordTest < ActiveSupport::TestCase
  setup do
    @tier = create(:noun, name: "Tier")
    @haustier = create(:noun, name: "Haustier")
    create(:noun, name: "Hund").keywords << [@tier, @haustier]
    create(:noun, name: "Wolf").keywords << @tier
  end

  test "words_count counts the words that carry all given keywords" do
    assert_equal 2, Keyword.words_count([@tier.id])
    assert_equal 1, Keyword.words_count([@tier.id, @haustier.id])
  end

  test "words_count accepts ids as strings" do
    assert_equal 1, Keyword.words_count([@tier.id.to_s, @haustier.id.to_s])
  end

  test "words_count never runs a keyword id as SQL" do
    injection = "0] <@ ARRAY[0]; UPDATE words SET name = 'pwned'; --"

    assert_equal 0, Keyword.words_count([injection])
    assert_equal "Tier", @tier.reload.name
  end

  test "words_count ignores ids that are not integers" do
    assert_equal 2, Keyword.words_count([@tier.id.to_s, "möchte ich folgenden Fehler melden:"])
  end
end
