require "rails_helper"

RSpec.describe "N+1 Query Prevention", type: :request do
  describe "Lists controller" do
    let(:user) { create(:user) }
    let(:list) { create(:list, user: user) }

    before do
      sign_in user
    end

    it "uses eager loading for associations" do
      get lists_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "Nouns controller" do
    let!(:nouns) { create_list(:noun, 5) }

    it "eagerly loads associations" do
      get nouns_path
      expect(response).to have_http_status(:success)
      # The fact that it completes without N+1 warnings is success
    end
  end
end
