# frozen_string_literal: true

# Replaces the RSpec.shared_examples "CRUD".
#
# Usage:
#
#   class NounsCrudTest < ApplicationSystemTestCase
#     extend CrudTests
#     crud_tests_for Noun
#   end
#
# Each call defines a self-contained set of test methods that exercise the
# create/read/update/destroy flow for the given AR class via the Capybara UI.
module CrudTests
  def crud_tests_for(klass)
    singular = klass.model_name.singular
    plural = klass.model_name.plural
    factory = singular.to_sym

    test "shows existing #{plural}" do
      login_as create(:admin)
      entry = create(factory)

      visit public_send(:"#{plural}_path")

      assert_text entry.name
    end

    test "edits an existing #{singular}" do
      login_as create(:admin)
      entry = create(factory)

      visit public_send(:"#{plural}_path")
      click_on entry.name
      click_on t("actions.edit"), match: :first
      fill_in "#{singular}[name]", with: "Anderer Name"
      click_on t("helpers.submit.update")

      entry.reload
      assert_equal "Anderer Name", entry.name
    end

    test "shows an error when updating an existing #{singular} with invalid data" do
      login_as create(:admin)
      entry = create(factory)

      visit public_send(:"#{plural}_path")
      click_on entry.name
      click_on t("actions.edit"), match: :first
      fill_in "#{singular}[name]", with: ""

      assert_no_difference -> { klass.count } do
        click_on t("helpers.submit.update")
      end
      assert_text t("errors.messages.blank")
    end

    test "deletes an existing #{singular}" do
      login_as create(:admin)
      entry = create(factory)

      visit public_send(:"#{plural}_path")
      click_on entry.name
      click_on t("actions.edit"), match: :first
      click_on t("actions.delete")

      assert_raises ActiveRecord::RecordNotFound do
        entry.reload
      end
    end

    test "creates a new #{singular}" do
      login_as create(:admin)

      visit public_send(:"#{plural}_path")
      click_on t("#{plural}.index.new")
      fill_in "#{singular}[name]", with: "Neuer Name"

      assert_difference -> { klass.count }, +1 do
        click_on t("helpers.submit.create")
      end

      assert_equal "Neuer Name", klass.last.name
    end

    test "shows an error when creating a new #{singular} with invalid data" do
      login_as create(:admin)

      visit public_send(:"#{plural}_path")
      click_on t("#{plural}.index.new")

      assert_no_difference -> { klass.count } do
        click_on t("helpers.submit.create")
      end

      assert_text t("errors.messages.blank")
    end
  end
end
