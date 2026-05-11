# frozen_string_literal: true

module Forms
  class BulkEditSearch
    WORD_TYPES = %w[Noun Verb Adjective FunctionWord].freeze
    SEARCH_FIELDS = %w[name syllables].freeze

    attr_reader :q, :search_field, :word_type, :per_page, :missing_field

    def initialize(params)
      @q = params[:q].to_s.strip
      @search_field = params[:search_field].presence_in(SEARCH_FIELDS) || "name"
      @word_type = params[:word_type].presence_in(WORD_TYPES)
      @per_page = params[:per_page].to_i
      @missing_field = params[:missing_field].presence_in(BulkEdit::ALL_FIELDS)
    end

    def queried?
      q.present? || missing_field.present?
    end

    def results
      scope = q.present? ? Word.matching_pattern(q, field: search_field.to_sym) : Word.all
      scope = scope.where(type: word_type) if word_type
      scope = BulkEdit::FieldStrategy.for(missing_field).missing_scope(scope) if missing_field
      scope
        .includes(:hierarchy, :prefix, :postfix, :phenomenons, :strategies, :topics, :sources)
        .ordered_lexigraphically
    end

    def total_count
      @total_count ||= results.except(:includes).count
    end

    def to_h
      {
        q: @q.presence,
        search_field: @search_field,
        word_type: @word_type,
        per_page: (@per_page.positive? ? @per_page : nil),
        missing_field: @missing_field
      }.compact
    end
  end
end
