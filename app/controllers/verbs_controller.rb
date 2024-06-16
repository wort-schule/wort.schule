# frozen_string_literal: true

class VerbsController < PublicController
  include OpenGraph
  include Themeable
  include ListAddable

  load_and_authorize_resource except: :add_to_list

  before_action :set_open_graph_tags, only: :show

  def index
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: "Verb")
    ) or return
    @verbs = @filterrific.find.ordered_lexigraphically.page(params[:page])
  end

  def show
    @verb.hit!(session, request.user_agent)

    render ThemeComponent.new(word: @verb, theme: current_word_view_setting.theme_verb) if current_word_view_setting&.theme_verb.present?
  end

  def new
  end

  def create
    @verb.assign_compound_entities(params[:verb][:compound_entity_ids])

    if @verb.save
      redirect_to @verb, notice: t("notices.verbs.created", verb: @verb.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @verb.assign_compound_entities(params[:verb][:compound_entity_ids])

    if @verb.update(verb_params)
      @verb.compound_entities.each(&:save)

      redirect_to @verb, notice: t("notices.verbs.updated", verb: @verb.name)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @verb.destroy
    notice = if destroyed
      {notice: t("notices.verbs.destroyed", verb: @verb.name)}
    else
      {alert: t("alerts.verbs.destroyed", verb: @verb.name)}
    end

    redirect_to verbs_path, notice
  end

  def background_color
    "bg-white md:bg-gray-100"
  end

  private

  def page_title
    instance_variable_defined?(:@verb) ? @verb.name : super
  end

  def verb_params
    params.require(:verb).permit(
      :subjectless,
      :strong,
      :imperative_singular,
      :imperative_plural,
      :participle,
      :past_participle,
      :perfect_haben,
      :perfect_sein,
      :present_singular_1,
      :present_singular_2,
      :present_singular_3,
      :present_plural_1,
      :present_plural_2,
      :present_plural_3,
      :past_singular_1,
      :past_singular_2,
      :past_singular_3,
      :past_plural_1,
      :past_plural_2,
      :past_plural_3,
      *Word::ATTRIBUTES
    )
  end
end
