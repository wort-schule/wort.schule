# frozen_string_literal: true

class Flashcards
  SECTIONS = (1..5).to_a

  def self.add_list(learning_group, list)
    word_ids = list.word_ids

    learning_group.users.includes(flashcard_lists: :words).find_each do |user|
      existing_word_ids = user.flashcard_lists.joins(:words).pluck("words.id").uniq
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
    valid_word_ids = learning_group.lists.joins(:words).pluck("words.id").uniq

    learning_group.users.includes(flashcard_lists: :words).find_each do |user|
      SECTIONS.each do |section|
        list = user.flashcard_list(section)
        current_word_ids = list.word_ids
        obsolete_word_ids = current_word_ids - valid_word_ids

        list.words.delete(Word.where(id: obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end

  def self.add_user(learning_group, user)
    all_word_ids = learning_group.lists.joins(:words).pluck("words.id").uniq
    existing_word_ids = user.flashcard_lists.joins(:words).pluck("words.id").uniq
    new_word_ids = all_word_ids - existing_word_ids

    if new_word_ids.any?
      user.first_flashcard_list.words << Word.where(id: new_word_ids)
    end
  end

  def self.remove_user(learning_group, user)
    remove_word_ids = learning_group.lists.joins(:words).pluck("words.id").uniq
    word_ids_to_keep = user
      .learning_groups
      .where.not(id: learning_group.id)
      .joins(lists: :words)
      .pluck("words.id")
      .uniq
    word_ids_to_remove = remove_word_ids - word_ids_to_keep

    if word_ids_to_remove.any?
      SECTIONS.each do |section|
        list = user.flashcard_list(section)
        current_word_ids = list.word_ids
        obsolete_word_ids = current_word_ids & word_ids_to_remove

        list.words.delete(Word.where(id: obsolete_word_ids)) if obsolete_word_ids.present?
      end
    end
  end
end
