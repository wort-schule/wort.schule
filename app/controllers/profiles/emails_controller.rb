# frozen_string_literal: true

module Profiles
  class EmailsController < ApplicationController
    authorize_resource class: "User"

    def edit
      @user = current_user

      render "users/emails/edit"
    end
  end
end
