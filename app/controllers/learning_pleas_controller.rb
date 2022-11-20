# frozen_string_literal: true

class LearningPleasController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource :learning_group, through: :school
  load_and_authorize_resource through: :learning_group

  before_action :set_lists, only: :new

  def new
  end

  def create
    if @learning_plea.save
      Flashcards.add_list(@learning_group, @learning_plea.list)

      redirect_to [@school, @learning_group], notice: t("notices.learning_pleas.created", name: @learning_plea.list)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @learning_plea.destroy
    Flashcards.remove_obsolete_words(@learning_group)

    notice = if destroyed
      {notice: t("notices.learning_pleas.destroyed", name: @learning_plea.list)}
    else
      {alert: t("alerts.learning_pleas.destroyed", name: @learning_plea.list)}
    end

    redirect_to [@school, @learning_plea.learning_group], notice
  end

  private

  def learning_plea_params
    params.require(:learning_plea).permit(
      :list_id
    )
  end

  def set_lists
    @lists = List
      .where(visibility: :public)
      .where.not(id: @learning_group.lists.to_a)
  end
end
