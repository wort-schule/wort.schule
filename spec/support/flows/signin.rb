# frozen_string_literal: true

module Flows
  class Signin < Flows::SiteFlow
    def sign_in(email:, password:)
      fill_in User.human_attribute_name(:email), with: email
      fill_in User.human_attribute_name(:password), with: password

      within ".box" do
        click_on t("devise.sessions.new.sign_in")
      end
    end
  end
end
