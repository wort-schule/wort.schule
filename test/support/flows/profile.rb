# frozen_string_literal: true

require_relative "site_flow"

module Flows
  class Profile < Flows::SiteFlow
    def change_password(old_password:, new_password:)
      fill_in User.human_attribute_name(:password), with: new_password
      fill_in User.human_attribute_name(:password_confirmation), with: new_password
      fill_in User.human_attribute_name(:current_password), with: old_password
      click_on t("helpers.submit.update")
    end

    def change_email(new_email:, current_password:)
      fill_in User.human_attribute_name(:email), with: new_email
      fill_in User.human_attribute_name(:current_password), with: current_password
      click_on t("helpers.submit.update")
    end
  end
end
