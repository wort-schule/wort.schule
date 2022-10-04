# frozen_string_literal: true

module Profiles
  class PasswordsController < ApplicationController
    authorize_resource class: "User"

    def edit
      @user = current_user

      render "users/passwords/edit"
    end
  end
end
