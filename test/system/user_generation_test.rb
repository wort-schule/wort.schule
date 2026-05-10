# frozen_string_literal: true

require "application_system_test_case"

class UserGenerationTest < ApplicationSystemTestCase
  setup do
    @admin = create(:admin)
    @learning_group = create(:learning_group)
    login_as @admin
  end

  test "creates user accounts" do
    generated_accounts_count = User.all.to_a.count { |user| user.generated_account? }

    visit learning_group_path(@learning_group)
    click_on t("learning_groups.show.generate_accounts")

    fill_in t("learning_groups.user_generations.new.amount"), with: 2
    assert_difference -> { User.count }, +2 do
      click_on t("actions.create")
    end

    assert_equal generated_accounts_count + 2, User.all.to_a.count { |user| user.generated_account? }
  end
end
