# frozen_string_literal: true

RSpec.describe "image requests" do
  let(:noun) { create(:noun) }
  let(:user) { create(:user) }
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
end
