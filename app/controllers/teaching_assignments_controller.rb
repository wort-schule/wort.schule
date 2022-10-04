# frozen_string_literal: true

class TeachingAssignmentsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  before_action :set_teachers, only: %i[new create]

  def new
  end

  def create
    if @teaching_assignment.save
      redirect_to @school, notice: t("notices.teaching_assignments.created", name: @teaching_assignment.teacher.decorate.display_name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @teaching_assignment.destroy
    notice = if destroyed
      {notice: t("notices.teaching_assignments.destroyed", name: @teaching_assignment.teacher.decorate.display_name)}
    else
      {alert: t("alerts.teaching_assignments.destroyed", name: @teaching_assignment.teacher.decorate.display_name)}
    end

    redirect_to @teaching_assignment.school, notice
  end

  private

  def teaching_assignment_params
    params.require(:teaching_assignment).permit(
      :teacher_id
    )
  end

  def set_teachers
    @teachers = Teacher
      .accessible_by(current_ability)
      .where.not(id: @school.teachers)
  end
end
