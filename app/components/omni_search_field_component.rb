# frozen_string_literal: true

class OmniSearchFieldComponent < ViewComponent::Base
  include Heroicon::ApplicationHelper

  attr_reader :form, :words

  def initialize(form:, words:, on_search_page: false)
    @form = form
    @words = words
    @on_search_page = on_search_page
  end

  def on_search_page?
    !!@on_search_page
  end

  def input_data_attribute
    if on_search_page?
      {
        action: "input->form-submission#search"
      }
    else
      {
        action: "input->form-submission#search keydown->home-search#input",
        "home-search-target": "input"
      }
    end
  end
end
