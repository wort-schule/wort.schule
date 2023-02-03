# frozen_string_literal: true

class ListsController < ApplicationController
  load_and_authorize_resource except: :move_word
  skip_forgery_protection only: :move_word
  authorize_resource only: :move_word

  def index
    @lists = @lists
      .order(:name)
      .page(params[:page])
  end

  def show
    @words = @list.words.ordered_lexigraphically.page(params[:page])
  end

  def new
  end

  def create
    @list.user = current_user
    @list.visibility = :private unless can? :create_private, List

    if @list.save
      redirect_to @list, notice: t("notices.shared.created", name: @list.name, class_name: List.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: t("notices.shared.updated", name: @list.name, class_name: List.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destroyed = @list.destroy
    notice = if destroyed
      {notice: t("notices.shared.destroyed", name: @list.name, class_name: List.model_name.human)}
    else
      {alert: t("alerts.shared.destroyed", name: @list.name)}
    end

    redirect_to lists_url, notice
  end

  def add_word
    @word = Word.find params[:word_id]
    @list.words << @word
    @list.learning_groups.find_each do |learning_group|
      Flashcards.add_list(learning_group, @list)
    end

    redirect_to @list
  end

  def remove_word
    @list.words.delete(params[:word_id])
    Flashcards.remove_word(@list, Word.find(params[:word_id]))

    redirect_to @list
  end

  def move_word
    target_list = List.unscoped.accessible_by(current_ability).find(params[:id])
    word = Word.find(params[:word_id])
    current_list = current_user.flashcard_lists.find { |list| list.words.exists?(word.id) }

    return head :unprocessable_entity if current_list == target_list

    ActiveRecord::Base.transaction do
      current_list.words.delete(word)
      target_list.words << word
    end

    respond_to do |format|
      format.turbo_stream do
        @lists = current_user.flashcard_lists
        @old_list = current_list
        @new_list = target_list
        @word = word
      end
      format.html { redirect_to flashcards_path }
    end
  end

  private

  def list_params
    params.require(:list).permit(
      :name, :description, :visibility
    )
  end
end
