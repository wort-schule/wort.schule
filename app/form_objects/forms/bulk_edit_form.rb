# frozen_string_literal: true

module Forms
  class BulkEditForm
    include ActiveModel::API
    include ActiveModel::Attributes

    attr_reader :params, :user, :field, :operation, :strategy, :value

    validates :field, presence: true, inclusion: {in: BulkEdit::ALL_FIELDS}
    validates :operation, presence: true
    validate :value_normalized
    validate :word_ids_present
    validate :word_count_within_limit
    validate :operation_allowed_for_field

    def initialize(params, user:)
      @params = params
      @user = user
      @field = params[:field].presence
      @operation = params[:operation].presence
      @strategy = (BulkEdit::FieldStrategy.for(@field) if BulkEdit::ALL_FIELDS.include?(@field))
      @value = @strategy&.normalize_input(params[:value])
    end

    def select_all?
      ActiveModel::Type::Boolean.new.cast(params[:select_all])
    end

    def explicit_ids
      @explicit_ids ||= Array(params[:selected_ids]).map(&:to_i).reject(&:zero?).uniq
    end

    def word_count
      @word_count ||= (select_all? ? search.total_count : explicit_ids.size)
    end

    def word_ids_for_apply
      @word_ids_for_apply ||= select_all? ? search.results.except(:includes).pluck(:id) : explicit_ids
    end

    def to_service_args
      {
        word_ids: word_ids_for_apply,
        field: field,
        operation: operation,
        value: value,
        search_query: params[:q].presence,
        missing_field: search.missing_field
      }
    end

    def preserved_search_params
      search.to_h
    end

    private

    def search
      @search ||= Forms::BulkEditSearch.new(params)
    end

    def value_normalized
      return unless @strategy
      errors.add(:value, :blank) if @value.nil?
    end

    def word_ids_present
      errors.add(:base, :no_words_selected) if word_count.zero?
    end

    def word_count_within_limit
      return if word_count <= BulkEdit::MAX_WORDS_PER_OPERATION
      errors.add(:base, :too_many_words, max: BulkEdit::MAX_WORDS_PER_OPERATION)
    end

    def operation_allowed_for_field
      return unless @strategy && @operation
      return if @strategy.operations.include?(@operation)
      errors.add(:operation, :invalid_for_field)
    end
  end
end
