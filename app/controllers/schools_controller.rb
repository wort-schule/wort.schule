# frozen_string_literal: true

class SchoolsController < ApplicationController
  load_and_authorize_resource

  def index
    @schools = @schools.order(:name).page(params[:path])
  end

  def show
  end

  def new
  end

  def create
    if @school.save
      redirect_to @school, notice: t("notices.schools.created", name: @school.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @school.update(school_params)
      redirect_to @school, notice: t("notices.schools.updated", name: @school.name)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @school.destroy
    notice = if destroyed
      {notice: t("notices.schools.destroyed", name: @school.name)}
    else
      {alert: t("alerts.schools.destroyed", name: @school.name)}
    end

    redirect_to schools_path, notice
  end

  private

  def school_params
    params.require(:school).permit(
      :name
    )
  end
end
