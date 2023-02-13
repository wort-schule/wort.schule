# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def destroy
      super do
        # Turbo requires redirects be :see_other (303); so override Devise default (302)
        return redirect_to after_sign_out_path_for(resource_name), status: :see_other
      end
    end

    def after_sign_in_path_for(resource)
      return edit_profile_path if resource.full_name.blank?

      super
    end
  end
end
