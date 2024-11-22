# frozen_string_literal: true

class ReviewsController < ApplicationController
  authorize_resource :review, class: false

  before_action :set_reviewable, only: %i[show update]

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_next_review

  def index
    redirect_to_next_review
  end

  def show
  end

  def update
    has_skipped = params[:state] == "skipped"
    confirmed = params.dig(:change_group, :word_attribute_edits_attributes)&.values&.map do |attributes|
      existing = @reviewable.word_attribute_edits.find { |word_attribute_edit| word_attribute_edit.id.to_s == attributes[:id] }

      human_proposed_value = attributes[:value]&.strip
      existing.errors.add(:value, :blank) if human_proposed_value.blank?
      proposal_not_changed = existing.proposed_value == human_proposed_value
      params[:state] == "confirmed" && proposal_not_changed && human_proposed_value.present?
    end&.all?

    if has_skipped || confirmed
      @reviewable.store_review(
        reviewer: current_user,
        state: params[:state]
      )

      return redirect_to_next_review
    end

    if @reviewable.word_attribute_edits.any? { |word_attribute_edit| word_attribute_edit.errors.present? }
      return render :show, status: :unprocessable_entity
    end

    @reviewable.transaction do
      successor = ChangeGroup.create!(state: :waiting_for_review)
      @reviewable.word_attribute_edits.each do |word_attribute_edit|
        WordAttributeEdit
          .create!(
            change_group: successor,
            word: word_attribute_edit.word,
            attribute_name: word_attribute_edit.attribute_name,
            value: params.dig(:change_group, :word_attribute_edits_attributes)&.values&.find { |attributes| attributes[:id] == word_attribute_edit.id.to_s }&.dig(:value)
          )
      end

      @reviewable.update!(
        state: :edited,
        successor:
      )

      Review.create!(
        state: :edited,
        reviewable: @reviewable,
        reviewer: current_user
      )
    end

    redirect_to_next_review
  end

  private

  def set_reviewable
    @reviewable = ChangeGroup.find(params[:id])
  end

  def redirect_to_next_review
    @next_review = ChangeGroup.reviewable(current_user).first

    if @next_review
      redirect_to review_path(@next_review)
    else
      redirect_to reviews_path unless params[:action] == "index"
    end
  end
end
