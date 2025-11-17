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

      it "redirects to root_path" do
        get "/debug"
        expect(response).to redirect_to(root_path)
      end

      it "shows alert message" do
        get "/debug"
        expect(flash[:alert]).to eq("Unauthorized")
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

      context "with LLM invocations" do
        before { sign_in admin }

        it "displays word identifier as clickable link for word enrichment" do
          word = create(:noun, name: "Haus")
          create(:word_llm_invocation,
            key: "Noun##{word.id}",
            invocation_type: "enrichment",
            state: "completed")

          get "/debug"
          expect(response.body).to include(polymorphic_path(word))
          expect(response.body).to include("Noun##{word.id}")
          expect(response.body).to include(word.name)
        end

        it "displays word information for check_base_form invocations" do
          create(:word_llm_invocation,
            key: "Hund#Animals#Noun",
            invocation_type: "check_base_form",
            state: "completed")

          get "/debug"
          expect(response.body).to include("Hund")
          expect(response.body).to include("Animals")
        end
      end

      context "with word imports" do
        before { sign_in admin }

        it "displays word import information with name and topic" do
          create(:word_import,
            name: "Katze",
            topic: "Pets",
            word_type: "Noun",
            state: "completed")

          get "/debug"
          expect(response.body).to include("Katze")
          expect(response.body).to include("Pets")
        end
      end
    end
  end
end
