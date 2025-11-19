# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = @users.order(:email).page(params[:page])
  end

  def show
  end

  def new
  end

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex

    if @user.save
      @user.send_reset_password_instructions

      redirect_to user_path(@user), notice: t("notices.users.created", email: @user.email)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to user_path(@user), notice: t("notices.users.updated", email: @user.email)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @user.destroy
    notice = if destroyed
      {notice: t("notices.users.destroyed", email: @user.email)}
    else
      {alert: t("alerts.users.destroyed", email: @user.email)}
    end

    redirect_to users_path, notice
  end

  private

  def page_title
    case action_name
    when "index"
      User.model_name.human(count: 2)
    when "show"
      t("users.show.title")
    when "new"
      t("users.new.title")
    when "edit"
      t("users.edit.title")
    end
  end
  helper_method :page_title

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :role
    )
  end
end
