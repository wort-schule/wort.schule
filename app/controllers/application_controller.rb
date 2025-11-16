class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include WordViewSettingsHelper

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_word_view_setting

  helper_method :page_title
  helper_method :background_color
  helper_method :full_width?

  private

  def page_title
    ""
  end

  def background_color
    "bg-gray-100"
  end

  def full_width?
    false
  end
end
