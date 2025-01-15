# frozen_string_literal: true

RSpec.describe WordImagesController, type: :request do
  let(:admin) { create :admin }

  context "as a guest" do
    it "does not have access" do
      get word_images_path

      expect(response).to have_http_status 302
    end
  end

  context "as an admin" do
    before do
      sign_in admin
    end

    context "without words" do
      it "is empty" do
        get word_images_path

        expect(response.body).to include I18n.t("word_images.index.empty")
      end
    end

    context "with words" do
      let!(:word_without_image) { create :noun, name: "Katze" }
      let!(:word_with_image) { create :adjective, name: "schön" }
      let(:filename) { "word.png" }

      before do
        word_with_image.image.attach(
          filename:,
          io: StringIO.new(file_fixture("avatar1.png").read)
        )
      end

      it "shows only words with images" do
        get word_images_path

        expect(response.body).to include word_with_image.name
        expect(response.body).to include filename
        expect(response.body).not_to include word_without_image.name
      end
    end
  end
end
