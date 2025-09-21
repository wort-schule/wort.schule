# frozen_string_literal: true

class CompoundInterfixesController < ApplicationController
  load_and_authorize_resource

  def index
    @compound_interfixes = @compound_interfixes.order(:name).page(params[:page])
  end

  def show
    @words = @compound_interfix.words.page(params[:page])
  end

  def new
  end

  def create
    if @compound_interfix.save
      redirect_to @compound_interfix, notice: t("notices.shared.created", name: @compound_interfix.name, class_name: CompoundInterfix.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @compound_interfix.update(compound_interfix_params)
      redirect_to @compound_interfix, notice: t("notices.shared.updated", name: @compound_interfix.name, class_name: CompoundInterfix.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @compound_interfix.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @compound_interfix.name, class_name: CompoundInterfix.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @compound_interfix.name)}
    end

    redirect_to compound_interfixes_url, notice
  end

  private

  def compound_interfix_params
    params.require(:compound_interfix).permit(
      :name
    )
  end
end
