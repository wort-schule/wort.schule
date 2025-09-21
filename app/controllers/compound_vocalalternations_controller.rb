# frozen_string_literal: true

class CompoundVocalalternationsController < ApplicationController
  load_and_authorize_resource

  def index
    @compound_vocalalternations = @compound_vocalalternations.order(:name).page(params[:page])
  end

  def show
    @words = @compound_vocalalternation.words.page(params[:page])
  end

  def new
  end

  def create
    if @compound_vocalalternation.save
      redirect_to @compound_vocalalternation, notice: t("notices.shared.created", name: @compound_vocalalternation.name, class_name: CompoundVocalalternation.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @compound_vocalalternation.update(compound_vocalalternation_params)
      redirect_to @compound_vocalalternation, notice: t("notices.shared.updated", name: @compound_vocalalternation.name, class_name: CompoundVocalalternation.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @compound_vocalalternation.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @compound_vocalalternation.name, class_name: CompoundVocalalternation.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @compound_vocalalternation.name)}
    end

    redirect_to compound_vocalalternations_url, notice
  end

  private

  def compound_vocalalternation_params
    params.require(:compound_vocalalternation).permit(
      :name
    )
  end
end
