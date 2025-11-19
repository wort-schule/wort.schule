# frozen_string_literal: true

class PendingReviewsController < ApplicationController
  authorize_resource :review, class: false

  def index
    @change_groups = fetch_pending_reviews
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"

    @change_groups = sort_change_groups(@change_groups, @sort_by, @sort_direction)
  end

  private

  def fetch_pending_reviews
    ChangeGroup.where(state: :waiting_for_review)
      .where(successor_id: nil)
      .includes(:word_attribute_edits, :new_word, :reviews)
      .order(created_at: :desc)
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
