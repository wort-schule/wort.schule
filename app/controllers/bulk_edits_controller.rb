# frozen_string_literal: true

class BulkEditsController < ApplicationController
  authorize_resource class: false

  def index
    @bulk_edits = BulkEdit
      .recent_first
      .includes(:user)
      .page(params[:log_page])
      .per(20)
    @pending_count = BulkEdit.where(undone_at: nil).count
    @search = Forms::BulkEditSearch.new(params)
    return unless @search.queried?

    @words_total_count = @search.total_count
    base = @search.results
    per_page = @search.per_page
    @per_page = if per_page <= 0
      0
    elsif per_page.zero?
      50
    else
      per_page
    end
    @words = (@per_page == 0) ? base : base.page(params[:page]).per(@per_page)
  end

  def create
    form = Forms::BulkEditForm.new(params, user: current_user)
    return redirect_with(form, alert: form.errors.full_messages.to_sentence) unless form.valid?

    bulk_edit = BulkEditService.new(user: current_user).execute(**form.to_service_args)
    if bulk_edit
      redirect_with(form, notice: t(".success", count: bulk_edit.affected_count))
    else
      redirect_with(form, alert: t(".no_changes"))
    end
  end

  def undo
    bulk_edit = BulkEdit.find(params[:id])
    raise CanCan::AccessDenied unless bulk_edit.undoable_by?(current_user)

    BulkEditService.new(user: current_user).undo(bulk_edit)
    redirect_to bulk_edits_path(anchor: "protokoll"), notice: t(".success")
  rescue BulkEditService::AlreadyUndone
    redirect_to bulk_edits_path(anchor: "protokoll"), alert: t(".already_undone")
  end

  def details
    @bulk_edit = BulkEdit.includes(word_changes: :word).find(params[:id])
    render partial: "protocol_changes", locals: {bulk_edit: @bulk_edit}
  end

  private

  def redirect_with(form, flash_args)
    redirect_to bulk_edits_path(form.preserved_search_params), **flash_args
  end
end
