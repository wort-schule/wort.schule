# frozen_string_literal: true

module FontHelper
  def current_font
    current_user&.word_font || Fonts.by_key(params[:font]) || Fonts.default
  end
end
