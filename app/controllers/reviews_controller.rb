# frozen_string_literal: true

class ReviewsController < ApplicationController
  authorize_resource :review, class: false

  before_action :set_reviewable, only: %i[show new create update]

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_next_review

  def index
    redirect_to_next_review
  end

  def show
  end

  def new
  end

  def create
    if @reviewable.value == params[:word_attribute_edit][:value]
      @reviewable.errors.add(:value, t(".must_be_different"))

      return render :new, status: :unprocessable_entity
    end

    @reviewable.transaction do
      successor = WordAttributeEdit
        .create!(
          word: @reviewable.word,
          attribute_name: @reviewable.attribute_name,
          value: params[:word_attribute_edit][:value],
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

  def update
    @reviewable.store_review(
      reviewer: current_user,
      state: params[:state]
    )

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
