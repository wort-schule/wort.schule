# frozen_string_literal: true

class LearningGroupMembershipsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource :learning_group, through: :school
  load_and_authorize_resource through: :learning_group

  before_action :set_students, only: :new

  def new
  end

  def create
    @learning_group_membership.access = "granted"

    if @learning_group_membership.save
      redirect_to [@school, @learning_group], notice: t("notices.learning_group_memberships.created", name: @learning_group_membership.student)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @learning_group_membership.destroy
    notice = if destroyed
      {notice: t("notices.learning_group_memberships.destroyed", name: @learning_group_membership.student)}
    else
      {alert: t("alerts.learning_group_memberships.destroyed", name: @learning_group_membership.student)}
    end

    redirect_to [@school, @learning_group_membership.learning_group], notice
  end

  private

  def learning_group_membership_params
    if current_user.student?
      {}
    else
      params.require(:learning_group_membership).permit(
        :student_id
      )
    end
  end

  def set_students
    @students = Student
      .accessible_by(current_ability)
      .where.not(id: @learning_group.students.to_a)
  end
end
