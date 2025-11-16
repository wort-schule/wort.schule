# frozen_string_literal: true

RSpec.describe "function words" do
  it_behaves_like "CRUD", FunctionWord
end

RSpec.describe "topics" do
  it_behaves_like "CRUD", Topic
end

RSpec.describe "hierarchies" do
  it_behaves_like "CRUD", Hierarchy
end

RSpec.describe "prefixes" do
  it_behaves_like "CRUD", Prefix
end

RSpec.describe "postfix" do
  it_behaves_like "CRUD", Postfix
end

RSpec.describe "phenomenons" do
  it_behaves_like "CRUD", Phenomenon
end

RSpec.describe "strategies" do
  it_behaves_like "CRUD", Strategy
end

RSpec.describe "compound interfixes" do
  it_behaves_like "CRUD", CompoundInterfix
end

RSpec.describe "compound preconfixes" do
  it_behaves_like "CRUD", CompoundPreconfix
end

RSpec.describe "compound postconfixes" do
  it_behaves_like "CRUD", CompoundPostconfix
end

RSpec.describe "compound phonemreductions" do
  it_behaves_like "CRUD", CompoundPhonemReduction
end

RSpec.describe "compound vocal alternations" do
  it_behaves_like "CRUD", CompoundVocalalternation
end
