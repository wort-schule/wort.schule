require "rails_helper"

RSpec.describe "Debug Dashboard", type: :request do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  describe "GET /debug" do
    context "when user is not authenticated" do
      it "redirects to login" do
        get "/debug"
        expect(response).to redirect_to(/devise\/users\/sign_in/)
      end
    end

    context "when user is not an admin" do
      before { sign_in user }

      it "returns 404 not found" do
        get "/debug"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is an admin" do
      before { sign_in admin }

      it "returns http success" do
        get "/debug"
        expect(response).to have_http_status(:success)
      end

      it "displays LLM service status" do
        create(:llm_service, api_key: "test-key", active: true)
        get "/debug"
        expect(response.body).to include("LLM Service Status")
      end

      it "displays queue statistics" do
        get "/debug"
        expect(response.body).to include("Queue Statistics")
        expect(response.body).to include("Pending Jobs")
      end

      it "displays LLM invocations section" do
        get "/debug"
        expect(response.body).to include("Recent LLM Invocations")
      end

      it "displays word imports section" do
        get "/debug"
        expect(response.body).to include("Recent Word Imports")
      end

      it "displays help section" do
        get "/debug"
        expect(response.body).to include("How to Debug LLM Issues")
      end
    end
  end
end
