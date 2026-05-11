# frozen_string_literal: true

class BulkEditChangesController < ApplicationController
  authorize_resource :bulk_edit, class: false

  def undo
    change = BulkEditChange.includes(:bulk_edit, :word).find(params[:id])
    raise CanCan::AccessDenied unless change.bulk_edit.undoable_by?(current_user)

    BulkEditService.new(user: current_user).undo_change(change)
    render partial: "bulk_edits/protocol_changes", locals: {bulk_edit: change.bulk_edit.reload}
  rescue BulkEditService::AlreadyReverted
    head :unprocessable_entity
  end
end
