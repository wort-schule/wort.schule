# frozen_string_literal: true

class ListsController < ApplicationController
  load_and_authorize_resource

  def index
    @lists = @lists
      .order(:name)
      .page(params[:page])
  end

  def show
    @words = @list.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    @list.user = current_user

    if @list.save
      redirect_to @list, notice: t("notices.shared.created", name: @list.name, class_name: List.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: t("notices.shared.updated", name: @list.name, class_name: List.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @list.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @list.name, class_name: List.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @list.name)}
    end

    redirect_to lists_url, notice
  end

  def add_word
    @word = Word.find params[:word_id]
    @list.words << @word

    redirect_to @list
  end

  def remove_word
    @list.words.delete(params[:word_id])

    redirect_to @list
  end

  private

  def list_params
    params.require(:list).permit(
      :name, :description, :visibility
    )
  end
end
