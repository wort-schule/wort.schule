# frozen_string_literal: true

class PostfixesController < ApplicationController
  load_and_authorize_resource

  def index
    @postfixes = @postfixes.order(:name).page(params[:page])
  end

  def show
    @words = @postfix.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @postfix.save
      redirect_to @postfix, notice: t("notices.shared.created", name: @postfix.name, class_name: Postfix.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @postfix.update(postfix_params)
      redirect_to @postfix, notice: t("notices.shared.updated", name: @postfix.name, class_name: Postfix.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @postfix.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @postfix.name, class_name: Postfix.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @postfix.name)}
    end

    redirect_to postfixes_url, notice
  end

  private

  def postfix_params
    params.require(:postfix).permit(
      :name
    )
  end
end
