# frozen_string_literal: true

RSpec.describe "verbs" do
  it_behaves_like "CRUD", Verb
  it_behaves_like "TTS", Verb
end
