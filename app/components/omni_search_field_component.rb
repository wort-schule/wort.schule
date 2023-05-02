# frozen_string_literal: true

class OmniSearchFieldComponent < ViewComponent::Base
  include Heroicon::ApplicationHelper

  attr_reader :form, :total_count

  def initialize(form:, total_count:, on_search_page: false)
    @form = form
    @on_search_page = on_search_page
    @total_count = total_count
  end

  def on_search_page?
    !!@on_search_page
  end

  def input_data_attribute
    {
      action: "input->form-submission#search keyup->home-search#input",
      "home-search-target": "input"
    }
  end
end
