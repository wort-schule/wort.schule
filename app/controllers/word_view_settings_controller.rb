# frozen_string_literal: true

class WordViewSettingsController < ApplicationController
  include CrudActions

  load_and_authorize_resource

  def create
    @word_view_setting.owner = current_user
    super
  end

  private

  def permitted_attributes
    [
      :name,
      :visibility,
      :theme_noun_id,
      :theme_verb_id,
      :theme_adjective_id,
      :theme_function_word_id,
      :font,
      :show_house,
      :show_syllable_arcs,
      :color_syllables,
      :show_horizontal_lines,
      :show_montessori_symbols,
      :show_fresch_symbols,
      :show_gender_symbols,
      :word_type_wording,
      :genus_wording,
      :numerus_wording
    ]
  end
end
