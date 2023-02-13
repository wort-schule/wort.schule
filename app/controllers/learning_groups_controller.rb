# frozen_string_literal: true

class LearningGroupsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
  end

  def new
  end

  def create
    @learning_group.owner = current_user

    if @learning_group.save
      redirect_to @learning_group, notice: t("notices.shared.created", name: @learning_group.name, class_name: LearningGroup.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @learning_group.update(learning_group_params)
      redirect_to @learning_group, notice: t("notices.shared.updated", name: @learning_group.name, class_name: LearningGroup.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @learning_group.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @learning_group.name, class_name: LearningGroup.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @learning_group.name)}
    end

    redirect_to learning_groups_path, notice
  end

  private

  def learning_group_params
    params.require(:learning_group).permit(
      :name,
      :user_id,
      :theme_noun_id,
      :theme_verb_id,
      :theme_adjective_id,
      :theme_function_word_id
    )
  end
end
