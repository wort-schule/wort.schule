# frozen_string_literal: true

class Reviews::NewWordComponent < ViewComponent::Base
  attr_reader :change_group

  delegate :new_word, to: :change_group

  def initialize(change_group:)
    @change_group = change_group
  end

  def duplicates_exist?
    words_with_other_topics.present? || words_with_other_topics_from_llm.present?
  end

  def words_with_other_topics
    @words_with_other_topics ||= Word.where(name: new_word.name)
  end

  def words_with_other_topics_from_llm
    @words_with_other_topics_from_llm ||= Word.where(name: new_word.llm_name)
  end
end
