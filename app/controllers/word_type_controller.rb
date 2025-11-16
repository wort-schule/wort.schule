# frozen_string_literal: true

class WordTypeController < PublicController
  include OpenGraph
  include Themeable
  include ListAddable

  load_and_authorize_resource except: :add_to_list
  before_action :set_open_graph_tags, only: :show

  def index
    @filterrific = initialize_filterrific(
      Word,
      (params[:filterrific] || {}).merge(filter_type: word_type)
    ) or return

    instance_variable_set(:"@#{controller_name}", filtered_words)
  end

  def show
    resource.hit!(session, request.user_agent)

    respond_to do |format|
      format.html do
        render ThemeComponent.new(word: resource, theme: theme_setting)
      end
      format.json do
        render "show", locals: {resource_name.to_sym => resource}
      end
    end
  end

  def new
  end

  def create
    assign_compound_entities if respond_to?(:assign_compound_entities?, true)

    if resource.save
      redirect_to resource, notice: create_notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    assign_compound_entities if respond_to?(:assign_compound_entities?, true)

    if resource.update(resource_params)
      resource.compound_entities.each(&:save) if resource.respond_to?(:compound_entities)
      redirect_to resource, notice: update_notice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = resource.destroy
    notice = if destroyed
      {notice: destroy_notice}
    else
      {alert: destroy_alert}
    end

    redirect_to url_for(action: :index), notice
  end

  def background_color
    "bg-white md:bg-gray-100"
  end

  private

  def page_title
    resource&.name || super
  end

  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  def resource_name
    controller_name.singularize
  end

  def word_type
    controller_name.singularize.camelize
  end

  def filtered_words
    @filterrific.find
      .includes(:topics, :keywords, :synonyms, :image_attachment, :hierarchy, :sources, :phenomenons, :strategies)
      .ordered_lexigraphically
      .page(params[:page])
  end

  def theme_setting
    method_name = "theme_#{resource_name}"
    current_word_view_setting.send(method_name)
  end

  def resource_params
    raise NotImplementedError, "Subclasses must implement #resource_params"
  end

  def assign_compound_entities?
    params[resource_name] && params[resource_name][:compound_entity_ids].present?
  end

  def assign_compound_entities
    return unless params[resource_name] && params[resource_name][:compound_entity_ids]
    resource.assign_compound_entities(params[resource_name][:compound_entity_ids])
  end

  def create_notice
    t("notices.#{controller_name}.created", resource_name => resource.name)
  rescue
    t("notices.shared.created", name: resource.name, class_name: resource.class.model_name.human)
  end

  def update_notice
    t("notices.#{controller_name}.updated", resource_name => resource.name)
  rescue
    t("notices.shared.updated", name: resource.name, class_name: resource.class.model_name.human)
  end

  def destroy_notice
    t("notices.#{controller_name}.destroyed", resource_name => resource.name)
  rescue
    t("notices.shared.destroyed", name: resource.name, class_name: resource.class.model_name.human)
  end

  def destroy_alert
    t("alerts.#{controller_name}.destroyed", resource_name => resource.name)
  rescue
    t("alerts.shared.destroyed", name: resource.name)
  end
end
