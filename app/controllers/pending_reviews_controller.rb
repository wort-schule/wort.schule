# frozen_string_literal: true

class PendingReviewsController < ApplicationController
  authorize_resource :review, class: false

  def index
    @change_groups = fetch_pending_reviews
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"
    @filter = params[:filter]&.strip
    @word_type_filter = params[:word_type_filter]
    @keyword_filter = params[:keyword_filter]&.strip

    # Apply filters if present
    if @filter.present? || @word_type_filter.present? || @keyword_filter.present?
      matching_ids = find_matching_change_groups(@filter, @word_type_filter, @keyword_filter)
      @change_groups = @change_groups.where(id: matching_ids)
    end

    @change_groups = sort_change_groups(@change_groups, @sort_by, @sort_direction)

    # Pagination
    @per_page = (params[:per_page] || 250).to_i
    @change_groups = Kaminari.paginate_array(@change_groups).page(params[:page]).per(@per_page)
  end

  def delete_filtered
    # Check if deletion was requested via checkbox
    if params[:delete_filtered] != "1"
      # Just apply filters without deletion
      redirect_to pending_reviews_path(
        filter: params[:filter],
        word_type_filter: params[:word_type_filter],
        keyword_filter: params[:keyword_filter],
        sort_by: params[:sort_by],
        sort_direction: params[:sort_direction],
        per_page: params[:per_page]
      )
      return
    end

    filter = params[:filter]&.strip
    word_type_filter = params[:word_type_filter]
    keyword_filter = params[:keyword_filter]&.strip

    if filter.blank? && word_type_filter.blank? && keyword_filter.blank?
      redirect_to pending_reviews_path, alert: t("pending_reviews.index.no_filter_provided")
      return
    end

    # Find matching change groups
    matching_ids = find_matching_change_groups(filter, word_type_filter, keyword_filter)

    if matching_ids.empty?
      @no_matches = true
      @filter = filter
      @word_type_filter = word_type_filter
      @keyword_filter = keyword_filter
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
    session[:pending_deletion_filter] = [filter, word_type_filter, keyword_filter].compact.join(", ")

    # Redirect to confirmation
    redirect_to confirm_delete_pending_reviews_path(
      count: matching_ids.count,
      filter: session[:pending_deletion_filter]
    )
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

  def find_matching_change_groups(filter, word_type_filter, keyword_filter)
    matching_ids = []

    # Start with all change groups if no name filter
    if filter.present?
      # Convert wildcard pattern to SQL LIKE pattern
      sql_pattern = filter.tr("*?", "%_")

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
    else
      # If no name filter, start with all change groups
      matching_ids = fetch_pending_reviews.pluck(:id)
    end

    # Apply word type filter
    if word_type_filter.present?
      type_filtered_ids = []

      # Filter word_attribute_edits by word type
      word_ids = Word.where(type: word_type_filter).pluck(:id)
      if word_ids.any?
        cg_ids = WordAttributeEdit.joins(:change_group)
          .where(word_id: word_ids)
          .where(change_groups: {state: :waiting_for_review, successor_id: nil})
          .pluck(:change_group_id)
        type_filtered_ids.concat(cg_ids)
      end

      # Filter new_words by word type
      new_word_cg_ids = NewWord.joins(:change_group)
        .where(word_type: word_type_filter)
        .where(change_groups: {state: :waiting_for_review, successor_id: nil})
        .pluck(:change_group_id)
      type_filtered_ids.concat(new_word_cg_ids)

      # Intersect with existing matching IDs
      matching_ids &= type_filtered_ids.uniq
    end

    # Apply keyword filter
    if keyword_filter.present?
      # Convert wildcard pattern to SQL LIKE pattern
      keyword_pattern = keyword_filter.tr("*?", "%_")

      # Find keywords matching the name pattern
      keyword_ids = Word.where("name ILIKE ?", keyword_pattern).pluck(:id)

      if keyword_ids.any?
        # Find word_attribute_edits that reference these keywords
        keyword_filtered_ids = WordAttributeEdit.joins(:change_group)
          .where(attribute_name: "keywords")
          .where(change_groups: {state: :waiting_for_review, successor_id: nil})
          .select { |edit|
            # Parse the value field to extract keyword IDs
            ids = extract_ids_from_value(edit.value)
            (ids & keyword_ids).any?
          }
          .map(&:change_group_id)

        # Intersect with existing matching IDs
        matching_ids &= keyword_filtered_ids.uniq
      else
        # No matching keywords found, return empty result
        matching_ids = []
      end
    end

    matching_ids.uniq
  end

  def extract_ids_from_value(value)
    case value
    when Array
      value.select { |item| item.is_a?(Integer) || (item.is_a?(String) && item.to_i.to_s == item) }
        .map { |item| item.is_a?(Integer) ? item : item.to_i }
    when String
      # Try to parse as JSON first
      begin
        parsed = JSON.parse(value)
        extract_ids_from_value(parsed)
      rescue JSON::ParserError
        # If not JSON, treat as comma-separated string
        value.split(",").map(&:strip).map(&:to_i).reject(&:zero?)
      end
    else
      []
    end
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
