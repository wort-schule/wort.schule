# frozen_string_literal: true

class BulkEditsController < ApplicationController
  authorize_resource class: false

  def index
    @bulk_edits = BulkEdit.recent_first.page(params[:log_page]).per(20)
    search_words if params[:q].present?
  end

  def execute
    word_ids = Array(params[:word_ids]).map(&:to_i).reject(&:zero?)
    values = Array(params[:values]).reject(&:blank?)

    if word_ids.empty?
      redirect_to bulk_edits_path(q: params[:q]), alert: t(".no_words_selected")
      return
    end

    if params[:field].blank?
      redirect_to bulk_edits_path(q: params[:q]), alert: t(".no_field_selected")
      return
    end

    service = BulkEditService.new(user: current_user)
    bulk_edit = service.execute(
      word_ids: word_ids,
      field: params[:field],
      operation: params[:operation] || "set",
      values: values,
      search_query: params[:q]
    )

    redirect_to bulk_edits_path(q: params[:q], word_type: params[:word_type], per_page: params[:per_page]),
      notice: t(".success", count: bulk_edit.affected_words_count)
  end

  def undo
    bulk_edit = BulkEdit.find(params[:id])
    BulkEditService.new(user: current_user).undo(bulk_edit)

    redirect_to bulk_edits_path(anchor: "protokoll"), notice: t(".undo_success")
  end

  private

  def search_words
    @words = build_search_query
    @words = @words.where(type: params[:word_type]) if params[:word_type].present?

    @words_total_count = @words.count
    @per_page = params[:per_page].to_i

    @words = if @per_page == 0
      @words.all
    else
      @per_page = 50 if @per_page <= 0
      @words.page(params[:page]).per(@per_page)
    end
  end

  def build_search_query
    q = params[:q].strip
    search_field = params[:search_field] || "name"

    pattern = build_like_pattern(q)

    case search_field
    when "syllables"
      Word.where("words.syllables ILIKE ?", pattern).ordered_lexigraphically
    else
      Word.where("words.name ILIKE ?", pattern).ordered_lexigraphically
    end
  end

  def build_like_pattern(q)
    starts_with = q.start_with?("^")
    ends_with = q.end_with?("$")
    q = q.delete_prefix("^").delete_suffix("$")
    q = Word.replace_regex(q)

    prefix = starts_with ? "" : "%"
    suffix = ends_with ? "" : "%"
    "#{prefix}#{q}#{suffix}"
  end
end
