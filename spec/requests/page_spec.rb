require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /impressum" do
    it "returns http success" do
      get "/page/impressum"
      expect(response).to have_http_status(:success)
    end
  end

end
