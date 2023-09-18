# frozen_string_literal: true

class FilterMode
  attr_reader :mode

  def initialize(mode:)
    @mode = (mode.presence || "omni").clamped(%i[omni advanced power], default: "omni", strict: false).to_sym
  end

  def show_panel?
    %i[advanced power].include?(mode)
  end

  def show_power_options?
    mode == :power
  end
end
