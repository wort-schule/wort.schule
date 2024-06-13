# frozen_string_literal: true

module FontHelper
  def current_font
    current_user&.word_font&.dig(:filename) || params[:font] || Fonts.default[:filename]
  end
end
