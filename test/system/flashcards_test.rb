# frozen_string_literal: true

require "application_system_test_case"

class FlashcardsTest < ApplicationSystemTestCase
  test "creates flash card lists when user is created" do
    user = create(:guest)

    assert_equal (1..5).to_a.sort, user.lists.unscoped.map(&:flashcard_section).sort
    assert_equal ["Fach 1", "Fach 2", "Fach 3", "Fach 4", "Fach 5"], user.lists.unscoped.map(&:to_s).sort
  end

  test "adds words to the first section and removes the word when list is removed" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    user = create(:guest)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    LearningGroupMembership.create!(learning_group:, user:, access: :granted)
    login_as lecturer

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    login_as user
    visit flashcards_path
    assert_text noun1.name
    assert_text noun2.name

    login_as lecturer
    visit learning_group_path(learning_group)
    within "##{dom_id(learning_group.learning_pleas.first)}" do
      click_on t("actions.remove")
    end

    login_as user
    visit flashcards_path
    assert_no_text noun1.name
    assert_no_text noun2.name
  end

  test "adds and removes words when modifying the list" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    user = create(:guest)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    LearningGroupMembership.create!(learning_group:, user:, access: :granted)
    login_as lecturer

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    noun3 = create(:noun, name: "Baum")
    visit noun_path(noun3)
    select word_list.name
    click_on I18n.t("words.show.lists.add")
    # add_word redirects to the list page; wait for that landing so the
    # subsequent login swap doesn't race the in-flight POST on slow CI.
    assert_current_path list_path(word_list)

    login_as user
    visit flashcards_path
    assert_text noun1.name
    assert_text noun2.name
    assert_text noun3.name

    login_as lecturer
    visit list_path(word_list)
    within "##{dom_id(noun3)}" do
      click_on I18n.t("actions.remove")
    end
    assert_no_selector "##{dom_id(noun3)}"

    login_as user
    visit flashcards_path
    assert_text noun1.name
    assert_text noun2.name
    assert_no_text noun3.name
  end

  test "removes words when removing a user" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    user = create(:guest)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    login_as lecturer

    LearningGroupMembership.create!(learning_group:, user:, access: :granted)

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    login_as lecturer
    visit learning_group_path(learning_group)
    within "##{dom_id(user)}" do
      click_on t("actions.remove")
    end

    user.reload
    assert_empty user.flashcard_list(1).words

    login_as user
    visit flashcards_path
    assert_no_text noun1.name
    assert_no_text noun2.name
  end

  test "adds words when adding a user" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    user = create(:guest)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    login_as lecturer

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a

    click_on t("learning_groups.show.assign_user")
    fill_in t("activerecord.attributes.learning_group_membership.user"), with: user.email
    click_on t("learning_group_memberships.new.assign")

    login_as user
    visit profile_path
    click_on t("profiles.show.accept")

    user.reload
    assert user.learning_group_memberships.present?
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    visit flashcards_path
    assert_text noun1.name
    assert_text noun2.name
  end

  test "does not remove a word when it is also in another learning group" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    user = create(:guest)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    login_as lecturer

    LearningGroupMembership.create!(learning_group:, user:, access: :granted)

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    other_learning_group = create(:learning_group, owner: lecturer)
    other_word_list = create(:list, user: lecturer, visibility: :public)
    other_word_list.words << noun1
    LearningGroupMembership.create!(learning_group: other_learning_group, user:, access: :granted)

    visit learning_group_path(other_learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    within "##{dom_id(other_word_list)}" do
      click_on t("learning_pleas.new.assign")
    end

    assert_equal [other_word_list], other_learning_group.lists.to_a
    assert_equal [noun1, noun2].sort_by(&:id), user.flashcard_list(1).words.sort_by(&:id)

    login_as lecturer
    visit learning_group_path(learning_group)
    within "##{dom_id(user)}" do
      click_on t("actions.remove")
    end

    user.reload
    assert_equal [noun1], user.flashcard_list(1).words

    login_as user
    visit flashcards_path
    assert_text noun1.name
    assert_no_text noun2.name
  end

  test "adds words when generating a user" do
    lecturer = create(:lecturer)
    learning_group = create(:learning_group, owner: lecturer)
    word_list = create(:list, user: lecturer, visibility: :public)
    noun1 = create(:noun, name: "Adler")
    noun2 = create(:noun, name: "Wolke")

    word_list.words << noun1
    word_list.words << noun2
    login_as lecturer

    assert_empty learning_group.users

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.assign_list")
    assert_text t("learning_pleas.new.title")
    click_on t("learning_pleas.new.assign")

    assert_equal [word_list], learning_group.lists.to_a

    click_on t("learning_groups.show.generate_accounts")
    fill_in t("learning_groups.user_generations.new.amount"), with: "1"
    click_on t("actions.create")

    generated_user = learning_group.users.first
    assert generated_user.confirmed?
    assert_equal [noun1, noun2].sort_by(&:id), generated_user.flashcard_list(1).words.sort_by(&:id)

    login_as generated_user
    visit flashcards_path
    assert_text noun1.name
    assert_text noun2.name
  end
end
