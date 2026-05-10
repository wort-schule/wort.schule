# frozen_string_literal: true

require "test_helper"

class GlobalSettingTest < ActiveSupport::TestCase
  test ".reviews_required returns the configured value" do
    GlobalSetting.create!(key: "reviews_required", integer_value: 2)
    assert_equal 2, GlobalSetting.reviews_required
  end

  test ".reviews_required defaults to 1 if not found" do
    GlobalSetting.where(key: "reviews_required").delete_all
    assert_equal 1, GlobalSetting.reviews_required
  end

  test ".reviews_required= creates a new record if it doesn't exist" do
    GlobalSetting.where(key: "reviews_required").delete_all
    GlobalSetting.reviews_required = 3
    assert_equal 3, GlobalSetting.reviews_required
  end

  test ".reviews_required= updates existing record" do
    GlobalSetting.reviews_required = 2
    assert_equal 2, GlobalSetting.reviews_required

    GlobalSetting.reviews_required = 5
    assert_equal 5, GlobalSetting.reviews_required
  end

  test "validates presence of key" do
    setting = GlobalSetting.new(integer_value: 1)
    refute setting.valid?
    assert setting.errors[:key].present?
  end

  test "validates uniqueness of key" do
    GlobalSetting.create!(key: "reviews_required", integer_value: 1)
    setting = GlobalSetting.new(key: "reviews_required", integer_value: 2)
    refute setting.valid?
    assert setting.errors[:key].present?
  end
end
