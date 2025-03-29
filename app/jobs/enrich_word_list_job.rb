# frozen_string_literal: true

class EnrichWordListJob < ApplicationJob
  queue_as :llm

  def perform(list_id)
    return if list_id.blank?

    list = List.find_by(id: list_id)
    return if list.blank?

    list.words.find_each do |word|
      EnrichWordJob.perform_later(word.id)
    end
  end
end
