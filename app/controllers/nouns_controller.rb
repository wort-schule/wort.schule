# frozen_string_literal: true

class NounsController < PublicController
  load_and_authorize_resource

  def index
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: "Noun")
    ) or return
    @nouns = @filterrific.find.ordered_lexigraphically.page(params[:page])
  end

  def by_genus
    nouns = Noun.by_genus(params[:genus]).ordered_lexigraphically.map do |noun|
      {
        text: noun.name,
        value: noun.id
      }
    end

    render json: nouns
  end

  def show
  end

  def new
    @noun.example_sentences.build if @noun.example_sentences.blank?
  end

  def create
    @noun.assign_compound_entities(params[:noun][:compound_entity_ids])

    if @noun.save
      redirect_to @noun, notice: t("notices.nouns.created", noun: @noun.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @noun.example_sentences.build if @noun.example_sentences.blank?
  end

  def update
    @noun.assign_compound_entities(params[:noun][:compound_entity_ids])

    if @noun.update(noun_params)
      @noun.compound_entities.each(&:save)

      redirect_to @noun, notice: t("notices.nouns.updated", noun: @noun.name)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @noun.destroy
    notice = if destroyed
      {notice: t("notices.nouns.destroyed", noun: @noun.name)}
    else
      {alert: t("alerts.nouns.destroyed", noun: @noun.name)}
    end

    redirect_to nouns_path, notice
  end

  private

  def noun_params
    params.require(:noun).permit(
      :plural,
      :genus_id,
      :singularetantum,
      :pluraletantum,
      :case_1_singular,
      :case_1_plural,
      :case_2_singular,
      :case_2_plural,
      :case_3_singular,
      :case_3_plural,
      :case_4_singular,
      :case_4_plural,
      :genus_neuter_id,
      :genus_masculine_id,
      :genus_feminine_id,
      *Word::ATTRIBUTES
    )
  end
end
