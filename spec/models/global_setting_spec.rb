# frozen_string_literal: true

RSpec.describe GlobalSetting do
  describe ".reviews_required" do
    it "returns the configured value" do
      GlobalSetting.create!(key: "reviews_required", integer_value: 2)
      expect(GlobalSetting.reviews_required).to eq 2
    end

    it "defaults to 1 if not found" do
      GlobalSetting.where(key: "reviews_required").delete_all
      expect(GlobalSetting.reviews_required).to eq 1
    end
  end

  describe ".reviews_required=" do
    it "creates a new record if it doesn't exist" do
      GlobalSetting.where(key: "reviews_required").delete_all
      GlobalSetting.reviews_required = 3
      expect(GlobalSetting.reviews_required).to eq 3
    end

    it "updates existing record" do
      GlobalSetting.reviews_required = 2
      expect(GlobalSetting.reviews_required).to eq 2

      GlobalSetting.reviews_required = 5
      expect(GlobalSetting.reviews_required).to eq 5
    end
  end

  describe "validations" do
    it "validates presence of key" do
      setting = GlobalSetting.new(integer_value: 1)
      expect(setting).not_to be_valid
      expect(setting.errors[:key]).to be_present
    end

    it "validates uniqueness of key" do
      GlobalSetting.create!(key: "reviews_required", integer_value: 1)
      setting = GlobalSetting.new(key: "reviews_required", integer_value: 2)
      expect(setting).not_to be_valid
      expect(setting.errors[:key]).to be_present
    end
  end
end
