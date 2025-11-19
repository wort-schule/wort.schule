# frozen_string_literal: true

class ReviewProcessor
  attr_reader :reviewable, :reviewer, :params

  def initialize(reviewable, reviewer, params)
    @reviewable = reviewable
    @reviewer = reviewer
    @params = params
  end

  def process
    return process_skip if skip_review?
    return process_word_attribute_edits if reviewable.word_attribute_edits.present?
    return process_new_word if reviewable.new_word.present?

    false
  end

  private

  def skip_review?
    %w[skipped discarded].include?(params[:state])
  end

  def process_skip
    reviewable.store_review(reviewer:, state: params[:state])

    if reviewable.new_word.present? && params[:state] == "discarded"
      send_discard_notification
    end

    true
  end

  def send_discard_notification
    return unless ENV["REVIEW_EXCEPTION_MAIL"].present?

    ReviewMailer.discarded(reviewable.new_word).deliver_later
  end

  def process_word_attribute_edits
    if all_confirmed?
      confirm_edits
      true
    elsif single_reviewer_mode? && any_value_submitted?
      confirm_edits_with_changes
      true
    elsif has_validation_errors?
      false
    else
      create_edited_version
      true
    end
  end

  def all_confirmed?
    return false unless params[:state] == "confirmed"

    word_edits_params.all? do |attributes|
      existing_edit = find_existing_edit(attributes[:id])
      human_value = normalize_value(attributes[:value])

      existing_edit.errors.add(:value, :blank) if human_value.blank?

      # Normalize both sides for comparison (convert numeric strings to integers)
      proposed = normalize_for_comparison(existing_edit.proposed_value)
      submitted = normalize_for_comparison(human_value)

      proposed == submitted && human_value.present?
    end
  end

  def single_reviewer_mode?
    params[:state] == "confirmed" && GlobalSetting.reviews_required == 1
  end

  def any_value_submitted?
    word_edits_params.all? do |attributes|
      existing_edit = find_existing_edit(attributes[:id])
      human_value = normalize_value(attributes[:value])

      # Only allow single-reviewer confirmation for keywords
      # where the submitted value is a non-empty subset of proposed values
      # Other array attributes (like synonyms) still require creating a new edit
      if human_value.present? && human_value.is_a?(Array) && existing_edit.attribute_name == "keywords"
        proposed = normalize_for_comparison(existing_edit.proposed_value)
        submitted = normalize_for_comparison(human_value)

        # All submitted values must be in the proposed values
        # (allows subset but not additions)
        submitted.all? { |v| proposed.include?(v) }
      else
        false
      end
    end
  end

  def confirm_edits_with_changes
    reviewable.transaction do
      # Apply the changes directly
      reviewable.word_attribute_edits.each do |word_attribute_edit|
        value = find_edit_value(word_attribute_edit.id.to_s)
        value = normalize_value(value)

        Llm::Attributes.update!(
          word: word_attribute_edit.word,
          attribute_name: word_attribute_edit.attribute_name,
          value: value
        )
      end

      # Mark as confirmed
      reviewable.update!(state: :confirmed)
      Review.create!(state: :confirmed, reviewable:, reviewer:)
    end
  end

  def confirm_edits
    reviewable.store_review(reviewer:, state: params[:state])
  end

  def has_validation_errors?
    reviewable.word_attribute_edits.any? { |edit| edit.errors.present? }
  end

  def create_edited_version
    reviewable.transaction do
      successor = create_successor_group
      copy_edits_to_successor(successor)
      finalize_edit(successor)
    end
  end

  def create_successor_group
    ChangeGroup.create!(state: :waiting_for_review)
  end

  def copy_edits_to_successor(successor)
    reviewable.word_attribute_edits.each do |original_edit|
      value = find_edit_value(original_edit.id.to_s)
      value = normalize_value(value)

      WordAttributeEdit.create!(
        change_group: successor,
        word: original_edit.word,
        attribute_name: original_edit.attribute_name,
        value: value.to_json
      )
    end
  end

  def finalize_edit(successor)
    reviewable.update!(state: :edited, successor:)
    Review.create!(state: :edited, reviewable:, reviewer:)
  end

  def process_new_word
    return handle_duplicate if duplicate?
    return false if invalid_new_word?

    create_word
    true
  end

  def duplicate?
    params[:state] == "duplicate" || find_duplicate_word.present?
  end

  def handle_duplicate
    reviewable.transaction do
      reviewable.reviews.create!(reviewer:, state: "duplicate")
      reviewable.update!(state: "duplicate")

      duplicate = find_duplicate_word
      reviewable.new_word.update!(duplicate_word: duplicate)
      reviewable.new_word.process_unlisted_keywords
    end
  end

  def find_duplicate_word
    return Word.find_by(id: params[:duplicate_word_id]) if params[:duplicate_word_id].present?

    Word.joins(:topics).find_by(
      type: new_word_params[:word_type],
      name: new_word_params[:name],
      "topics.name": new_word_params[:topic]
    )
  end

  def invalid_new_word?
    return false unless params[:state] == "created"

    [new_word_params[:word_type],
      new_word_params[:name],
      new_word_params[:topic]].any?(&:blank?)
  end

  def create_word
    reviewable.transaction do
      reviewable.reviews.create!(reviewer:, state: "created")

      topic = Topic.find_or_create_by!(name: new_word_params[:topic])

      created_word = Word.create!(
        name: new_word_params[:name],
        topics: [topic],
        type: new_word_params[:word_type]
      )

      reviewable.update!(state: "created")
      reviewable.new_word.update!(created_word_id: created_word.id)
      reviewable.new_word.process_unlisted_keywords

      EnrichWordJob.perform_later(created_word.id)
    end
  end

  def word_edits_params
    params.dig(:change_group, :word_attribute_edits_attributes)&.values || []
  end

  def new_word_params
    @new_word_params ||= params.dig(:change_group, :new_word_attributes) || {}
  end

  def find_existing_edit(id)
    reviewable.word_attribute_edits.find { |edit| edit.id.to_s == id }
  end

  def find_edit_value(id)
    word_edits_params.find { |attrs| attrs[:id] == id }&.dig(:value)
  end

  def normalize_value(value)
    return value unless value

    value = value.strip if value.is_a?(String)
    value = value.compact_blank if value.is_a?(Array)
    value = true if value == "1"
    value = false if value == "0"
    value
  end

  def normalize_for_comparison(value)
    return value unless value.is_a?(Array)

    # Convert numeric strings to integers for comparison
    value.map { |v| (v.to_s.to_i.to_s == v.to_s) ? v.to_i : v }
  end
end
