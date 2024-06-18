class AddMoreParamsToWordViewSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :word_view_settings, :show_house, :boolean, null: false, default: false
    add_column :word_view_settings, :show_syllable_arcs, :boolean, null: false, default: true
    add_column :word_view_settings, :color_syllables, :boolean, null: false, default: false
    add_column :word_view_settings, :show_horizontal_lines, :boolean, null: false, default: false
    add_column :word_view_settings, :show_montessori_symbols, :boolean, null: false, default: true
    add_column :word_view_settings, :show_fresch_symbols, :boolean, null: false, default: true
    add_column :word_view_settings, :show_gender_symbols, :boolean, null: false, default: true
  end
end
