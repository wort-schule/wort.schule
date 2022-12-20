# frozen_string_literal: true

RSpec.describe "adjectives" do
  it_behaves_like "CRUD", Adjective
  it_behaves_like "TTS", Adjective
end
