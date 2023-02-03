# frozen_string_literal: true

class LearningGroupMembershipsController < ApplicationController
  load_and_authorize_resource :learning_group
  load_and_authorize_resource through: :learning_group

  before_action :set_users, only: %i[new create]

  def new
  end

  def create
    @learning_group_membership.access = "granted"

    if @learning_group_membership.save
      redirect_to @learning_group, notice: t("notices.learning_group_memberships.created", name: @learning_group_membership.user)
    else
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

  private

  def learning_group_membership_params
    params.require(:learning_group_membership).permit(
      :user_id,
      :role
    )
  end

  def set_users
    @users = User
      .accessible_by(current_ability)
      .where.not(id: @learning_group.users.to_a)
  end
end
