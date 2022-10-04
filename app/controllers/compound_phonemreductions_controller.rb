# frozen_string_literal: true

class CompoundPhonemreductionsController < ApplicationController
  load_and_authorize_resource

  def index
    @compound_phonemreductions = @compound_phonemreductions.order(:name).page(params[:page])
  end

  def show
    @words = @compound_phonemreduction.words.page(params[:page])
  end

  def new
  end

  def create
    if @compound_phonemreduction.save
      redirect_to @compound_phonemreduction, notice: t("notices.shared.created", name: @compound_phonemreduction.name, class_name: CompoundPhonemreduction.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @compound_phonemreduction.update(compound_phonemreduction_params)
      redirect_to @compound_phonemreduction, notice: t("notices.shared.updated", name: @compound_phonemreduction.name, class_name: CompoundPhonemreduction.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @compound_phonemreduction.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @compound_phonemreduction.name, class_name: CompoundPhonemreduction.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @compound_phonemreduction.name)}
    end

    redirect_to compound_phonemreductions_url, notice
  end

  private

  def compound_phonemreduction_params
    params.require(:compound_phonemreduction).permit(
      :name
    )
  end
end
