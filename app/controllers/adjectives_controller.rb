# frozen_string_literal: true

class AdjectivesController < PublicController
  include OpenGraph
  include Themeable
  include ListAddable

  load_and_authorize_resource except: :add_to_list

  before_action :set_open_graph_tags, only: :show

  def index
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: "Adjective")
    ) or return
    @adjectives = @filterrific.find.ordered_lexigraphically.page(params[:page])
  end

  def show
    render ThemeComponent.new(word: @adjective, theme: current_user.theme_adjective) if current_user&.theme_adjective.present?
  end

  def new
  end

  def create
    @adjective.assign_compound_entities(params[:adjective][:compound_entity_ids])

    if @adjective.save
      redirect_to @adjective, notice: t("notices.adjectives.created", adjective: @adjective.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @adjective.assign_compound_entities(params[:adjective][:compound_entity_ids])

    if @adjective.update(adjective_params)
      @adjective.compound_entities.each(&:save)

      redirect_to @adjective, notice: t("notices.adjectives.updated", adjective: @adjective.name)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @adjective.destroy
    notice = if destroyed
      {notice: t("notices.adjectives.destroyed", adjective: @adjective.name)}
    else
      {alert: t("alerts.adjectives.destroyed", adjective: @adjective.name)}
    end

    redirect_to adjectives_path, notice
  end

  private

  def page_title
    instance_variable_defined?("@adjective") ? @adjective.name : super
  end

  def adjective_params
    params.require(:adjective).permit(
      :comparative,
      :superlative,
      :absolute,
      :irregular_comparison,
      :irregular_declination,
      *Word::ATTRIBUTES
    )
  end
end
