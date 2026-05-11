# frozen_string_literal: true

require "test_helper"

class BulkEditChangeTest < ActiveSupport::TestCase
  test "scopes split pending from reverted entries" do
    pending = create(:bulk_edit_change, reverted_at: nil)
    reverted = create(:bulk_edit_change, reverted_at: Time.current)

    assert_equal [pending], BulkEditChange.pending.to_a
    assert_equal [reverted], BulkEditChange.reverted.to_a
  end

  test "#reverted? reads from reverted_at" do
    refute build(:bulk_edit_change, reverted_at: nil).reverted?
    assert build(:bulk_edit_change, reverted_at: Time.current).reverted?
  end
end
