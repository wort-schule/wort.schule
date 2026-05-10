# frozen_string_literal: true

require "test_helper"

class HierarchyTest < ActiveSupport::TestCase
  setup do
    @hierarchy = create(:hierarchy)
    @word = create(:noun, hierarchy: @hierarchy)
  end

  test "deletes a hierarchy" do
    assert_equal @hierarchy, @word.hierarchy

    assert_difference -> { Hierarchy.count }, -1 do
      assert_no_difference -> { Word.count } do
        @hierarchy.destroy!
      end
    end

    assert_nil @word.reload.hierarchy
  end

  test "with children, makes the children a top level hierarchy" do
    child = create(:hierarchy, parent: @hierarchy)

    assert_equal [child], @hierarchy.children

    assert_difference -> { Hierarchy.count }, -1 do
      @hierarchy.destroy!
    end

    assert_nil @word.reload.hierarchy
    assert_nil child.reload.parent
  end
end
