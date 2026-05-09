# frozen_string_literal: true

# Wraps an LLM call in the WordLlmInvocation lifecycle: bail out if a
# matching invocation is already in flight, otherwise create one in
# state :invoked, run the block, transition to :completed on success or
# :failed (with a useful error message) on exception.
#
# Example:
#   include Llm::InvocationTracker
#
#   def call
#     track_invocation(key: "#{word.class}##{word.id}", invocation_type: :enrichment) do
#       # do the LLM work; result of last expression is returned by call
#     end
#   end
module Llm
  module InvocationTracker
    extend ActiveSupport::Concern

    attr_reader :word_llm_invocation

    private

    def track_invocation(key:, invocation_type:)
      return if WordLlmInvocation.exists?(
        key: key,
        invocation_type: invocation_type,
        state: %w[new invoked]
      )

      @word_llm_invocation = WordLlmInvocation.create!(
        key: key,
        invocation_type: invocation_type,
        state: :invoked
      )

      result = yield
      @word_llm_invocation.update!(state: :completed)
      result
    rescue => e
      @word_llm_invocation&.update!(state: :failed, error: invocation_error_message(e))
      raise e if @word_llm_invocation.blank?
    end

    def invocation_error_message(e)
      message = e.full_message
      return message unless e.respond_to?(:response) && e.response&.dig(:body).present?

      "#{message}\n\nAPI Response Body:\n#{e.response[:body]}"
    end
  end
end
