# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompoundPostconfixesController, type: :request do
  it_behaves_like "CRUD request spec", CompoundPostconfix, {name: "-keit"}, {name: ""}, {name: "-ung"}
end
