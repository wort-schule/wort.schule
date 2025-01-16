# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestImageComponent, type: :component do
  let(:user) { create(:user) }

  context "without an attached image" do
    let(:word) { create(:noun) }

    it "renders" do
      expect(
        render_inline(described_class.new(word:, user:)).to_html
      ).to include(I18n.t("request_image_component.request"))
    end

    context "with an existing image request" do
      let!(:image_request) { create(:image_request, user:, word:) }

      it "does not render" do
        expect(
          render_inline(described_class.new(word:, user:)).to_html
        ).to be_empty
      end
    end

    context "without a user" do
      let(:user) { nil }

      it "does not render" do
        expect(
          render_inline(described_class.new(word:, user:)).to_html
        ).to be_empty
      end
    end
  end

  context "with an attached image" do
    let(:word) { create(:noun).tap { |word| word.image.attach(filename: "word.png", io: StringIO.new(file_fixture("avatar1.png").read)) } }

    it "does not render" do
      expect(
        render_inline(described_class.new(word:, user:)).to_html
      ).to be_empty
    end
  end
end
