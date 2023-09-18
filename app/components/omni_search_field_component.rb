# frozen_string_literal: true

class OmniSearchFieldComponent < ViewComponent::Base
  include Heroicon::ApplicationHelper

  attr_reader :total_count

  def initialize(total_count:, on_search_page: false)
    @on_search_page = on_search_page
    @total_count = total_count
  end

  def search_value
    params.dig(:filterrific, :filter_home)
  end

  def search_input_id
    "omni_search"
  end

  def input_data_attribute
    if !!@on_search_page
      {
        action: "input->form-submission#search"
      }
    else
      {
        action: "input->form-submission#search keyup->home-search#input",
        "home-search-target": "input"
      }
    end
  end
end
