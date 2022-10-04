# frozen_string_literal: true

class AvatarsController < ApplicationController
  authorize_resource class: "User"

  def destroy
    current_user.avatar.purge

    redirect_to profile_path
  end
end
