# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordAttributeEdit do
  describe "#normalize_attribute_name" do
    let(:word) { create(:noun) }
    let(:change_group) { create(:change_group) }

    context "when attribute_name has a type prefix" do
      it "strips the prefix before saving" do
        edit = described_class.create!(
          word:,
          change_group:,
          attribute_name: "noun.case_1_plural",
          value: '["test"]'
        )

        expect(edit.attribute_name).to eq("case_1_plural")
      end

      it "handles verb prefixes" do
        verb = create(:verb)
        edit = described_class.create!(
          word: verb,
          change_group:,
          attribute_name: "verb.present_singular_1",
          value: '["test"]'
        )

        expect(edit.attribute_name).to eq("present_singular_1")
      end
    end

    context "when attribute_name has no prefix" do
      it "leaves the attribute_name unchanged" do
        edit = described_class.create!(
          word:,
          change_group:,
          attribute_name: "case_1_plural",
          value: '["test"]'
        )

        expect(edit.attribute_name).to eq("case_1_plural")
      end
    end

    context "when attribute_name is updated" do
      it "normalizes on update" do
        edit = described_class.create!(
          word:,
          change_group:,
          attribute_name: "case_1_plural",
          value: '["test"]'
        )

        edit.update!(attribute_name: "noun.meaning")

        expect(edit.attribute_name).to eq("meaning")
      end
    end
  end
end
