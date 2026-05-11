# frozen_string_literal: true

class BulkEdit < ApplicationRecord
  belongs_to :user
  has_many :word_changes, -> { order(:id) }, class_name: "BulkEditChange", dependent: :destroy, inverse_of: :bulk_edit

  HABTM_FIELDS = %w[topics strategies phenomenons sources].freeze
  BELONGS_TO_FIELDS = %w[hierarchy_id prefix_id postfix_id].freeze
  BOOLEAN_FIELDS = %w[prototype foreign compound].freeze
  ALL_FIELDS = (HABTM_FIELDS + BELONGS_TO_FIELDS + BOOLEAN_FIELDS).freeze
  OPERATIONS = %w[add remove set].freeze
  MAX_WORDS_PER_OPERATION = 5_000

  validates :operation, inclusion: {in: OPERATIONS}
  validates :field, inclusion: {in: ALL_FIELDS}
  validate :operation_allowed_for_field

  scope :recent_first, -> { order(created_at: :desc) }
  scope :undoable_by, ->(user) {
    (user.role == "Admin") ? all : where(user_id: user.id)
  }

  def strategy
    @strategy ||= BulkEdit::FieldStrategy.for(field)
  end

  def undone? = undone_at.present?

  def undoable? = !undone?

  def field_label = strategy.label

  def display_intent = strategy.display_value(intent_value)

  def undoable_by?(user)
    return false unless undoable?
    user.role == "Admin" || user_id == user.id
  end

  private

  def operation_allowed_for_field
    return if field.blank? || operation.blank?
    return unless ALL_FIELDS.include?(field)
    errors.add(:operation, :invalid_for_field) unless strategy.operations.include?(operation)
  end
end
