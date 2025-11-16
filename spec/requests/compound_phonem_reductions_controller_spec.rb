# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundPhonemReductionsController, type: :request do
  it_behaves_like "CRUD request spec", CompoundPhonemReduction, {name: "i→ø"}, {name: ""}, {name: "o→ø"}
end
