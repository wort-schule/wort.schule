# frozen_string_literal: true

RSpec.describe Hierarchy do
  subject { create(:hierarchy) }
  let!(:word) { create(:noun, hierarchy: subject) }

  it "deletes a hierarchy" do
    expect(word.hierarchy).to eq subject

    expect do
      subject.destroy!
    end.to change(Hierarchy, :count).by(-1)
      .and not_change(Word, :count)

    expect(word.reload.hierarchy).to be nil
  end

  context "with children" do
    let!(:child) { create(:hierarchy, parent: subject) }

    it "makes the children a top level hierarchy" do
      expect(subject.children).to eq [child]

      expect do
        subject.destroy!
      end.to change(Hierarchy, :count).by(-1)

      expect(word.reload.hierarchy).to be nil
      expect(child.reload.parent).to be nil
    end
  end
end
