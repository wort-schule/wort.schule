# frozen_string_literal: true

class TopicsController < ApplicationController
  load_and_authorize_resource

  def index
    @topics = @topics.order(:name).page(params[:page])
  end

  def show
    @words = @topic.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    if @topic.save
      redirect_to @topic, notice: t("notices.shared.created", name: @topic.name, class_name: Topic.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: t("notices.shared.updated", name: @topic.name, class_name: Topic.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @topic.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @topic.name, class_name: Topic.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @topic.name)}
    end

    redirect_to topics_url, notice
  end

  private

  def topic_params
    params.require(:topic).permit(
      :name
    )
  end
end
