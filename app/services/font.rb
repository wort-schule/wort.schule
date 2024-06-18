# frozen_string_literal: true

class Font
  attr_reader :name, :arc_settings

  def initialize(name:, filename:, arc_settings:)
    @name = name
    @filename = filename
    @arc_settings = arc_settings
  end

  def key
    @filename
  end

  def ttf_filepath
    Rails.root.join("app/assets/fonts/#{@filename}-Regular.ttf")
  end
end
