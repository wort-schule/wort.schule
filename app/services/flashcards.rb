# frozen_string_literal: true

class Flashcards
  SECTIONS = (1..5).to_a

  def self.add_list(learning_group, list)
    word_ids = list.word_ids

    learning_group.users.includes(flashcard_lists: {lists_words: :word}).find_each do |user|
      # Use eager-loaded data instead of additional query
      existing_word_ids = user.flashcard_lists.flat_map { |fl| fl.words.map(&:id) }.uniq
      new_word_ids = word_ids - existing_word_ids

      if new_word_ids.any?
        user.first_flashcard_list.words << Word.where(id: new_word_ids)
      end
    end
  end

  def self.remove_word(list, word)
    list.learning_groups.find_each do |learning_group|
      remove_obsolete_words(learning_group)
    end
  end

  def self.remove_obsolete_words(learning_group)
    # Single query to get all valid word IDs for this learning group
    valid_word_ids = Word
      .joins(lists: :learning_groups)
      .where(learning_groups: {id: learning_group.id})
      .distinct
      .pluck(:id)

    learning_group.users.includes(flashcard_lists: {lists_words: :word}).find_each do |user|
      SECTIONS.each do |section|
        list = user.flashcard_list(section)
        # Use eager-loaded data instead of additional query
        current_word_ids = list.words.map(&:id)
        obsolete_word_ids = current_word_ids - valid_word_ids

        list.words.delete(Word.where(id: obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end

  def self.add_user(learning_group, user)
    # Single query to get all word IDs for this learning group
    all_word_ids = Word
      .joins(lists: :learning_groups)
      .where(learning_groups: {id: learning_group.id})
      .distinct
      .pluck(:id)

    # Single query to get existing word IDs for this user's flashcard lists
    existing_word_ids = Word
      .joins(:lists)
      .where(lists: {user_id: user.id})
      .where.not(lists: {flashcard_section: nil})
      .distinct
      .pluck(:id)

    new_word_ids = all_word_ids - existing_word_ids

    if new_word_ids.any?
      user.first_flashcard_list.words << Word.where(id: new_word_ids)
    end
  end

  def self.remove_user(learning_group, user)
    # Single query to get words from the learning group being left
    remove_word_ids = Word
      .joins(lists: :learning_groups)
      .where(learning_groups: {id: learning_group.id})
      .distinct
      .pluck(:id)

    # Single query to get words from user's remaining learning groups
    word_ids_to_keep = Word
      .joins(lists: :learning_groups)
      .joins("INNER JOIN learning_group_memberships ON learning_group_memberships.learning_group_id = learning_groups.id")
      .where(learning_group_memberships: {user_id: user.id})
      .where.not(learning_groups: {id: learning_group.id})
      .distinct
      .pluck(:id)

    word_ids_to_remove = remove_word_ids - word_ids_to_keep

    if word_ids_to_remove.any?
      # Eager load flashcard lists with their words to avoid N+1
      user_lists = user.flashcard_lists.includes(:words).to_a

      SECTIONS.each do |section|
        list = user_lists.find { |l| l.flashcard_section == section } || user.flashcard_list(section)
        # Use eager-loaded data instead of additional query
        current_word_ids = list.words.map(&:id)
        obsolete_word_ids = current_word_ids & word_ids_to_remove

        list.words.delete(Word.where(id: obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end
end
