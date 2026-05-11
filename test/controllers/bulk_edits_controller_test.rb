# frozen_string_literal: true

require "test_helper"

class BulkEditsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin)
    @lecturer_a = create(:lecturer)
    @lecturer_b = create(:lecturer)
    @noun = create(:noun, name: "Haus")
    @phenomenon = create(:phenomenon, name: "P")
  end

  test "POST /seite/bulk_edits without a field redirects with an alert" do
    sign_in @admin
    post bulk_edits_path, params: {selected_ids: [@noun.id]}
    assert_response :redirect
    assert response.location.start_with?(bulk_edits_url)
  end

  test "POST /seite/bulk_edits/:id/undo by a foreign Lecturer raises CanCan::AccessDenied" do
    bulk_edit = BulkEditService.new(user: @lecturer_a).execute(
      word_ids: [@noun.id], field: "phenomenons", operation: "add", value: {"ids" => [@phenomenon.id]}
    )
    sign_in @lecturer_b

    assert_raises(CanCan::AccessDenied) { post undo_bulk_edit_path(bulk_edit) }
    assert_nil bulk_edit.reload.undone_at
  end

  test "POST /seite/bulk_edits/:bulk_edit_id/changes/:id/undo by a foreign Lecturer raises CanCan::AccessDenied" do
    bulk_edit = BulkEditService.new(user: @lecturer_a).execute(
      word_ids: [@noun.id], field: "phenomenons", operation: "add", value: {"ids" => [@phenomenon.id]}
    )
    change = bulk_edit.word_changes.first
    sign_in @lecturer_b

    assert_raises(CanCan::AccessDenied) do
      post undo_bulk_edit_change_path(bulk_edit_id: bulk_edit.id, id: change.id)
    end
    assert_nil change.reload.reverted_at
  end

  test "an Admin can undo any entry" do
    bulk_edit = BulkEditService.new(user: @lecturer_a).execute(
      word_ids: [@noun.id], field: "phenomenons", operation: "add", value: {"ids" => [@phenomenon.id]}
    )
    sign_in @admin

    post undo_bulk_edit_path(bulk_edit)
    assert_redirected_to bulk_edits_path(anchor: "protokoll")
    assert bulk_edit.reload.undone_at.present?
  end
end
