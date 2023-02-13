# frozen_string_literal: true

require_relative "site_flow"

module Flows
  class Signup < Flows::SiteFlow
    def sign_up(email:, password:)
      fill_in User.human_attribute_name(:email), with: email
      fill_in User.human_attribute_name(:password), match: :first, with: password
      fill_in User.human_attribute_name(:password_confirmation), with: password

      expect do
        click_on t("devise.registrations.new.sign_up")
      end.to change(User, :count).by 1

      User.find_by(email:).confirm

      visit new_user_session_path
      Flows::Signin.new.sign_in(email:, password:)
    end
  end
end
