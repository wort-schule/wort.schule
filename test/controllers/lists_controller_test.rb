# frozen_string_literal: true

require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  test "when logged in as a lecturer allows to create public lists" do
    user = create(:lecturer)
    sign_in user

    post lists_path, params: {
      list: {
        name: "Meine Wortliste",
        description: "Eine Beschreibung",
        visibility: :public
      }
    }

    list = List.last

    assert_redirected_to list_path(list)
    assert_equal "public", list.visibility
    assert_equal User.find(user.id), list.user
  end
end
