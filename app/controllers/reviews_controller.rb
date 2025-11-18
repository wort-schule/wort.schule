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
    processor = ReviewProcessor.new(@reviewable, current_user, params)

    if processor.process
      redirect_to_next_review
    elsif @reviewable.new_word.present? && processor.send(:invalid_new_word?)
      @reviewable.new_word.assign_attributes(
        word_type: params.dig(:change_group, :new_word_attributes, :word_type),
        name: params.dig(:change_group, :new_word_attributes, :name),
        topic: params.dig(:change_group, :new_word_attributes, :topic)
      )
      @reviewable.valid?
      render :show
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def page_title
    return "" unless @reviewable

    word_name = if @reviewable.word_attribute_edits.present?
      @reviewable.word_attribute_edits.first.word.name
    elsif @reviewable.new_word.present?
      @reviewable.new_word.name
    end

    return "Review" unless word_name

    "Review: #{word_name}"
  end

  def set_reviewable
    @reviewable = ChangeGroup
      .includes(word_attribute_edits: {word: {compound_entities: :part}})
      .find(params[:id])
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
