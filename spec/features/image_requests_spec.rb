# frozen_string_literal: true

RSpec.describe "image requests" do
  let(:noun) { create(:noun, meaning: "Meaning of the word") }
  let(:user) { create(:admin) }
  let(:request_button) { I18n.t("request_image_component.request") }

  before do
    login_as user
  end

  it "creates an image request" do
    visit noun_path(noun)

    expect do
      click_on request_button
    end.to change(ImageRequest, :count).by(1)

    expect(ImageRequest.last).to have_attributes(
      word: noun,
      user:
    )

    expect(page).not_to have_content request_button
  end

  context "with existing requests" do
    let!(:image_request) { create(:image_request, word: noun, user:) }
    let!(:other_image_request) { create(:image_request, word: noun, user: create(:user)) }
    let!(:another_image_request) { create(:image_request, word: noun, user: create(:user)) }

    it "lists requests" do
      visit image_requests_path

      expect(page).to have_content noun.name
      expect(page).to have_content noun.meaning
      expect(page).to have_content 3
    end
  end
end
