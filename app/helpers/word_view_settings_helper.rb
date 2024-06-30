# frozen_string_literal: true

module WordViewSettingsHelper
  def current_word_view_setting
    current_word_view_setting_from_session ||
      current_user&.word_view_setting ||
      current_user&.last_learning_group&.word_view_setting ||
      WordViewSetting.new
  end

  def current_word_view_setting_from_session
    word_view_setting_id = session[:word_view_setting_id]

    return if word_view_setting_id.blank?

    WordViewSetting
      .accessible_by(current_ability)
      .find_by(id: word_view_setting_id)
  end

  def set_word_view_setting
    word_view_setting_id = params[:word_view_setting_id]

    return if word_view_setting_id.blank?

    word_view_setting = WordViewSetting
      .accessible_by(current_ability)
      .find_by(id: word_view_setting_id)

    session[:word_view_setting_id] = word_view_setting&.id
    current_user&.update(word_view_setting:)
  end

  def word_type_wording_for(klass)
    WordTypes.label(
      current_word_view_setting.word_type_wording,
      klass.model_name.name
    )
  end

  def current_numerus_wording
    current_word_view_setting.numerus_wording
  end
end
