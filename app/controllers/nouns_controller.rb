# frozen_string_literal: true

class NounsController < PublicController
  include OpenGraph
  include Themeable
  include ListAddable

  load_and_authorize_resource except: :add_to_list

  before_action :set_open_graph_tags, only: :show

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
    @noun.hit!(session, request.user_agent)

    respond_to do |format|
      format.html do
        render ThemeComponent.new(word: @noun, theme: current_word_view_setting.theme_noun)
      end
      format.json do
        render "show", locals: {noun: @noun}
      end
    end
  end

  def new
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

  def background_color
    "bg-white md:bg-gray-100"
  end

  private

  def page_title
    instance_variable_defined?(:@noun) ? @noun.name : super
  end

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
