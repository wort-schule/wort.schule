# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundInterfixesController, type: :request do
  it_behaves_like "CRUD request spec", CompoundInterfix, {name: "-en-"}, {name: ""}, {name: "-er-"}
end
