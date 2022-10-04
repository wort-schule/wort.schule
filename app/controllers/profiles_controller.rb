# frozen_string_literal: true

class ProfilesController < ApplicationController
  authorize_resource class: "User"

  before_action :set_user

  def show
    @user = @user.decorate
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user)
      .permit(
        *current_ability.permitted_attributes(:update, @user)
      )
  end
end
