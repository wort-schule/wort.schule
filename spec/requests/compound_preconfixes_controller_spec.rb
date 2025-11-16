# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundPreconfixesController, type: :request do
  it_behaves_like "CRUD request spec", CompoundPreconfix, {name: "ver-"}, {name: ""}, {name: "ent-"}
end
