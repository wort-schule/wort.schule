# frozen_string_literal: true

class LearningGroupMembershipsController < ApplicationController
  load_and_authorize_resource :learning_group
  load_and_authorize_resource through: :learning_group

  def new
    @learning_group_membership.user_id = nil
  end

  def create
    email_or_username = learning_group_membership_params[:user_id]
    email = if email_or_username.include?("@")
      email_or_username
    else
      "#{email_or_username}@user.wort.schule"
    end

    @learning_group_membership.user = User.find_by(email:)
    @learning_group_membership.access = "invited"

    if @learning_group_membership.save
      LearningGroupMailer.with(
        learning_group_name: @learning_group_membership.learning_group.name,
        user: @learning_group_membership.user
      ).invite.deliver_later

      redirect_to @learning_group, notice: t("notices.learning_group_memberships.invited")
    else
      @learning_group_membership.user_id = learning_group_membership_params[:user_id]

      render :new, status: :unprocessable_entity
    end
  end

  def update
    @learning_group_membership.update!(learning_group_membership_params)

    redirect_to @learning_group_membership.learning_group
  end

  def destroy
    destroyed = @learning_group_membership.destroy
    notice = if destroyed
      {notice: t("notices.learning_group_memberships.destroyed", name: @learning_group_membership.user)}
    else
      {alert: t("alerts.learning_group_memberships.destroyed", name: @learning_group_membership.user)}
    end

    redirect_to @learning_group_membership.learning_group, notice
  end

  def reset_password
    @user = @learning_group_membership.user

    head :forbidden unless @user.generated_account?

    @new_password = UserAccountGenerator.new.generate_password
    @user.update!(password: @new_password)
  end

  private

  def learning_group_membership_params
    params.require(:learning_group_membership).permit(
      :user_id,
      :role
    )
  end
end
