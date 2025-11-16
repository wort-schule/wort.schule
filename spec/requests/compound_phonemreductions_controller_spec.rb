# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundPhonemreductionsController, type: :request do
  it_behaves_like "CRUD request spec", CompoundPhonemreduction, {name: "i→ø"}, {name: ""}, {name: "o→ø"}
end
