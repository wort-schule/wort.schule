# frozen_string_literal: true

class PendingReviewsController < ApplicationController
  authorize_resource :review, class: false

  def index
    @change_groups = fetch_pending_reviews
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"
    @filter = params[:filter]&.strip

    # Apply filter if present
    if @filter.present?
      matching_ids = find_matching_change_groups(@filter)
      @change_groups = @change_groups.where(id: matching_ids)
    end

    @change_groups = sort_change_groups(@change_groups, @sort_by, @sort_direction)

    # Pagination
    @per_page = (params[:per_page] || 250).to_i
    @change_groups = Kaminari.paginate_array(@change_groups).page(params[:page]).per(@per_page)
  end

  def delete_filtered
    filter = params[:filter]&.strip

    if filter.blank?
      redirect_to pending_reviews_path, alert: t("pending_reviews.index.no_filter_provided")
      return
    end

    # Find matching change groups
    matching_ids = find_matching_change_groups(filter)

    if matching_ids.empty?
      @no_matches = true
      @filter = filter
      # Re-fetch data for index view
      @change_groups = fetch_pending_reviews
      @sort_by = params[:sort_by] || "created_at"
      @sort_direction = params[:sort_direction] || "desc"
      @change_groups = sort_change_groups(@change_groups, @sort_by, @sort_direction)
      @per_page = (params[:per_page] || 250).to_i
      @change_groups = Kaminari.paginate_array(@change_groups).page(params[:page]).per(@per_page)
      render :index
      return
    end

    # Store the IDs in session for confirmation
    session[:pending_deletion_ids] = matching_ids
    session[:pending_deletion_filter] = filter

    # Redirect to confirmation
    redirect_to confirm_delete_pending_reviews_path(count: matching_ids.count, filter: filter)
  end

  def confirm_delete
    @count = params[:count].to_i
    @filter = params[:filter]
  end

  def destroy_confirmed
    ids = session.delete(:pending_deletion_ids)

    if ids.blank?
      redirect_to pending_reviews_path, alert: t("pending_reviews.index.session_expired")
      return
    end

    count = ChangeGroup.where(id: ids).destroy_all.count

    session.delete(:pending_deletion_filter)
    redirect_to pending_reviews_path, notice: t("pending_reviews.index.deletion_success", count: count)
  end

  private

  def fetch_pending_reviews
    ChangeGroup.where(state: :waiting_for_review)
      .where(successor_id: nil)
      .includes(:word_attribute_edits, :new_word, :reviews)
      .order(created_at: :desc)
  end

  def find_matching_change_groups(filter)
    # Convert wildcard pattern to SQL LIKE pattern
    sql_pattern = filter.tr("*?", "%_")

    # Find matching change groups
    matching_ids = []

    # Search in word_attribute_edits
    word_ids = Word.where("name ILIKE ?", sql_pattern).pluck(:id)
    if word_ids.any?
      cg_ids = WordAttributeEdit.joins(:change_group)
        .where(word_id: word_ids)
        .where(change_groups: {state: :waiting_for_review, successor_id: nil})
        .pluck(:change_group_id)
      matching_ids.concat(cg_ids)
    end

    # Search in new_words
    new_word_cg_ids = NewWord.joins(:change_group)
      .where("new_words.name ILIKE ?", sql_pattern)
      .where(change_groups: {state: :waiting_for_review, successor_id: nil})
      .pluck(:change_group_id)
    matching_ids.concat(new_word_cg_ids)

    matching_ids.uniq
  end

  def sort_change_groups(groups, sort_by, direction)
    norm_direction = ((direction == "asc") ? "ASC" : "DESC")

    case sort_by
    when "word_name"
      sorted = groups.sort_by do |cg|
        if cg.word_attribute_edits.present?
          cg.word_attribute_edits.first.word.name
        elsif cg.new_word.present?
          cg.new_word.name
        else
          ""
        end
      end
      (norm_direction == "DESC") ? sorted.reverse : sorted

    when "word_type"
      sorted = groups.sort_by do |cg|
        if cg.word_attribute_edits.present?
          cg.word_attribute_edits.first.word.class.name
        elsif cg.new_word.present?
          cg.new_word.word_type
        else
          ""
        end
      end
      (norm_direction == "DESC") ? sorted.reverse : sorted

    when "review_type"
      sorted = groups.sort_by do |cg|
        if cg.new_word.present?
          "a_new_word"
        else
          "b_attribute_edit"
        end
      end
      (norm_direction == "DESC") ? sorted.reverse : sorted

    when "created_at"
      if norm_direction == "ASC"
        groups.sort_by(&:created_at)
      else
        groups.sort_by(&:created_at).reverse
      end

    when "reviews_count"
      sorted = groups.sort_by { |cg| cg.reviews.count }
      (norm_direction == "DESC") ? sorted.reverse : sorted

    else
      groups
    end
  end
end
