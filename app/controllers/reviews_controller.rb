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
    human_proposed_value = params.dig(:word_attribute_edit, :value)&.strip
    proposal_not_changed = @reviewable.proposed_value == human_proposed_value
    confirmed = params[:state] == "confirmed" && proposal_not_changed && human_proposed_value.present?

    if has_skipped || confirmed
      @reviewable.store_review(
        reviewer: current_user,
        state: params[:state]
      )

      return redirect_to_next_review
    end

    if human_proposed_value.blank?
      @reviewable.errors.add(:value, :blank)

      return render :show, status: :unprocessable_entity
    end

    @reviewable.transaction do
      successor = WordAttributeEdit
        .create!(
          word: @reviewable.word,
          attribute_name: @reviewable.attribute_name,
          value: human_proposed_value,
          state: :waiting_for_review
        )

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
    @reviewable = WordAttributeEdit.find(params[:id])
  end

  def redirect_to_next_review
    @next_review = WordAttributeEdit.reviewable(current_user).first

    if @next_review
      redirect_to review_path(@next_review)
    else
      redirect_to reviews_path unless params[:action] == "index"
    end
  end
end
