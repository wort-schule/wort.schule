# frozen_string_literal: true

RSpec.describe CompoundInterfixesController, type: :request do
  let(:admin) { create :admin }
  let(:user) { create :user }

  describe "GET #index" do
    let!(:interfix1) { create :compound_interfix, name: "en" }
    let!(:interfix2) { create :compound_interfix, name: "es" }
    let!(:interfix3) { create :compound_interfix, name: "er" }

    context "when logged in as admin" do
      before { sign_in admin }

      it "displays all compound interfixes ordered by name" do
        get compound_interfixes_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("en", "er", "es")
      end

      it "paginates the results" do
        get compound_interfixes_path(page: 1)

        expect(response).to have_http_status(:success)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get compound_interfixes_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET #show" do
    let!(:interfix) { create :compound_interfix, name: "en" }
    let!(:noun) { create :noun, name: "Gartenhaus" }

    context "when logged in as admin" do
      before { sign_in admin }

      it "displays the compound interfix details" do
        get compound_interfix_path(interfix)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("en")
      end
    end
  end

  describe "GET #new" do
    context "when logged in as admin" do
      before { sign_in admin }

      it "displays the new form" do
        get new_compound_interfix_path

        expect(response).to have_http_status(:success)
      end
    end

    context "when logged in as regular user" do
      before { sign_in user }

      it "denies access" do
        expect {
          get new_compound_interfix_path
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "POST #create" do
    context "when logged in as admin" do
      before { sign_in admin }

      context "with valid params" do
        it "creates a new compound interfix" do
          expect {
            post compound_interfixes_path, params: {
              compound_interfix: {name: "en"}
            }
          }.to change(CompoundInterfix, :count).by(1)

          expect(response).to redirect_to(compound_interfix_path(CompoundInterfix.last))
          expect(flash[:notice]).to include("en")
        end
      end

      context "with invalid params" do
        it "renders the new template with errors" do
          post compound_interfixes_path, params: {
            compound_interfix: {name: ""}
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("new")
        end
      end
    end
  end

  describe "GET #edit" do
    let!(:interfix) { create :compound_interfix, name: "en" }

    context "when logged in as admin" do
      before { sign_in admin }

      it "displays the edit form" do
        get edit_compound_interfix_path(interfix)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("en")
      end
    end
  end

  describe "PATCH #update" do
    let!(:interfix) { create :compound_interfix, name: "en" }

    context "when logged in as admin" do
      before { sign_in admin }

      context "with valid params" do
        it "updates the compound interfix" do
          patch compound_interfix_path(interfix), params: {
            compound_interfix: {name: "es"}
          }

          expect(response).to redirect_to(compound_interfix_path(interfix))
          expect(interfix.reload.name).to eq("es")
          expect(flash[:notice]).to include("es")
        end
      end

      context "with invalid params" do
        it "renders the edit template with errors" do
          patch compound_interfix_path(interfix), params: {
            compound_interfix: {name: ""}
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("edit")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:interfix) { create :compound_interfix, name: "en" }

    context "when logged in as admin" do
      before { sign_in admin }

      it "destroys the compound interfix" do
        expect {
          delete compound_interfix_path(interfix)
        }.to change(CompoundInterfix, :count).by(-1)

        expect(response).to redirect_to(compound_interfixes_url)
        expect(flash[:notice]).to include("en")
      end
    end
  end
end
