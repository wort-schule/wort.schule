# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def update
    super do |user|
      if user.errors.present?
        return render "users/emails/edit" if account_update_params[:email].present?
        return render "users/passwords/edit" if account_update_params[:password].present?
      end
    end
  end

  def after_sign_up_path_for(_)
    edit_profile_path
  end
end
