# frozen_string_literal: true

class GlobalSettingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_settings

  def index
  end

  def update
    @reviews_required_setting.update!(integer_value: params[:reviews_required])
    redirect_to global_settings_path, notice: "Settings updated successfully"
  end

  private

  def set_settings
    @reviews_required_setting = GlobalSetting.find_or_create_by(key: "reviews_required") do |setting|
      setting.integer_value = 1
    end
  end
end
