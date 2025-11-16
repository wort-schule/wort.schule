# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundVocalalternationsController, type: :request do
  it_behaves_like "CRUD request spec", CompoundVocalalternation, {name: "u→ü"}, {name: ""}, {name: "e→i"}
end
