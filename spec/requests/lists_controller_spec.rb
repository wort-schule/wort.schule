# frozen_string_literal: true

RSpec.describe ListsController do
  before do
    sign_in user
  end

  context "when logged in as a user" do
    let(:user) { create :guest }

    it "does not allow to create public lists" do
      post lists_path, params: {
        list: {
          name: "Meine Wortliste",
          description: "Eine Beschreibung",
          visibility: :public
        }
      }

      list = List.last

      expect(response).to redirect_to list_path(list)
      expect(list.visibility).to eq :private
      expect(list.user).to eq User.find(user.id)
    end
  end

  context "when logged in as a lecturer" do
    let(:user) { create :lecturer }

    it "allows to create public lists" do
      post lists_path, params: {
        list: {
          name: "Meine Wortliste",
          description: "Eine Beschreibung",
          visibility: :public
        }
      }

      list = List.last

      expect(response).to redirect_to list_path(list)
      expect(list.visibility).to eq :public
      expect(list.user).to eq User.find(user.id)
    end
  end
end
