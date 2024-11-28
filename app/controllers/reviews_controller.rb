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
    has_skipped = %w[skipped discarded].include?(params[:state])

    if has_skipped
      @reviewable.store_review(
        reviewer: current_user,
        state: params[:state]
      )

      if @reviewable.new_word.present? && params[:state] == "discarded"
        ReviewMailer.discarded(@reviewable.new_word).deliver_later if ENV["REVIEW_EXCEPTION_MAIL"].present?
      end

      return redirect_to_next_review
    end

    if @reviewable.word_attribute_edits.present?
      confirmed = params.dig(:change_group, :word_attribute_edits_attributes)&.values&.map do |attributes|
        existing = @reviewable.word_attribute_edits.find { |word_attribute_edit| word_attribute_edit.id.to_s == attributes[:id] }

        human_proposed_value = attributes[:value]&.strip
        existing.errors.add(:value, :blank) if human_proposed_value.blank?
        proposal_not_changed = existing.proposed_value == human_proposed_value
        params[:state] == "confirmed" && proposal_not_changed && human_proposed_value.present?
      end&.all?

      if confirmed
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
    elsif @reviewable.new_word.present?
      @reviewable.transaction do
        corrected_word_type = params.dig(:change_group, :new_word_attributes, :word_type)
        corrected_name = params.dig(:change_group, :new_word_attributes, :name)
        corrected_topic = params.dig(:change_group, :new_word_attributes, :topic)

        duplicate_word = Word.find_by(id: params[:duplicate_word_id]) || Word.joins(:topics).find_by(type: corrected_word_type, name: corrected_name, "topics.name": corrected_topic)

        if params[:state] == "duplicate" || duplicate_word.present?
          @reviewable.reviews.create!(
            reviewer: current_user,
            state: "duplicate"
          )

          @reviewable.update!(state: "duplicate")
          @reviewable.new_word.update!(duplicate_word:)

          return redirect_to_next_review
        end

        if params[:state] == "created"
          if [corrected_word_type, corrected_name, corrected_topic].any?(&:blank?)
            @reviewable.new_word.assign_attributes(
              word_type: corrected_word_type,
              name: corrected_name,
              topic: corrected_topic
            )

            @reviewable.valid?

            return render :show
          end

          @reviewable.reviews.create!(
            reviewer: current_user,
            state: "created"
          )

          topic = Topic.find_or_create_by!(name: corrected_topic)

          created_word = Word.create!(
            name: corrected_name,
            topics: [topic],
            type: corrected_word_type
          )

          @reviewable.update!(state: "created")
          @reviewable.new_word.update!(created_word_id: created_word.id)

          return redirect_to_next_review
        end
      end
    else
      render :show, status: :unprocessable_entity
    end
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
