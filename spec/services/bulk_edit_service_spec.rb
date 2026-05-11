# frozen_string_literal: true

RSpec.describe BulkEditService do
  let(:admin) { create :admin }
  let(:service) { described_class.new(user: admin) }

  describe "#execute" do
    context "with HABTM fields" do
      let!(:noun1) { create :noun, name: "Haus" }
      let!(:noun2) { create :noun, name: "Baum" }
      let!(:phenomenon1) { create :phenomenon, name: "Doppelkonsonanz" }
      let!(:phenomenon2) { create :phenomenon, name: "Dehnungs-h" }

      it "adds phenomenons to words" do
        bulk_edit = service.execute(
          word_ids: [noun1.id, noun2.id],
          field: "phenomenons",
          operation: "add",
          values: [phenomenon1.id.to_s, phenomenon2.id.to_s],
          search_query: "test"
        )

        expect(noun1.reload.phenomenons).to include(phenomenon1, phenomenon2)
        expect(noun2.reload.phenomenons).to include(phenomenon1, phenomenon2)
        expect(bulk_edit.operation).to eq("add")
        expect(bulk_edit.word_ids).to contain_exactly(noun1.id, noun2.id)
        expect(bulk_edit.previous_values[noun1.id.to_s]).to contain_exactly(phenomenon1.id, phenomenon2.id)
      end

      it "only records delta for already-associated IDs" do
        noun1.phenomenons << phenomenon1

        bulk_edit = service.execute(
          word_ids: [noun1.id],
          field: "phenomenons",
          operation: "add",
          values: [phenomenon1.id.to_s, phenomenon2.id.to_s]
        )

        expect(noun1.reload.phenomenons).to contain_exactly(phenomenon1, phenomenon2)
        expect(bulk_edit.previous_values[noun1.id.to_s]).to eq([phenomenon2.id])
      end

      it "removes phenomenons from words" do
        noun1.phenomenons << [phenomenon1, phenomenon2]

        bulk_edit = service.execute(
          word_ids: [noun1.id],
          field: "phenomenons",
          operation: "remove",
          values: [phenomenon1.id.to_s]
        )

        expect(noun1.reload.phenomenons).to contain_exactly(phenomenon2)
        expect(bulk_edit.previous_values[noun1.id.to_s]).to eq([phenomenon1.id])
      end
    end

    context "with belongs_to fields" do
      let!(:noun) { create :noun, name: "Haus" }
      let!(:hierarchy1) { create :hierarchy }
      let!(:hierarchy2) { create :hierarchy }

      it "sets hierarchy on words" do
        noun.update!(hierarchy: hierarchy1)

        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "hierarchy_id",
          operation: "set",
          values: [hierarchy2.id.to_s]
        )

        expect(noun.reload.hierarchy).to eq(hierarchy2)
        expect(bulk_edit.previous_values[noun.id.to_s]).to eq(hierarchy1.id)
      end
    end

    context "with boolean fields" do
      let!(:noun) { create :noun, name: "Haus", prototype: false }

      it "sets boolean value on words" do
        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "prototype",
          operation: "set",
          values: ["true"]
        )

        expect(noun.reload.prototype).to be true
        expect(bulk_edit.previous_values[noun.id.to_s]).to be false
      end
    end
  end

  describe "#undo" do
    context "with HABTM add" do
      let!(:noun) { create :noun, name: "Haus" }
      let!(:phenomenon) { create :phenomenon }

      it "removes previously added associations" do
        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "phenomenons",
          operation: "add",
          values: [phenomenon.id.to_s]
        )

        expect(noun.reload.phenomenons).to include(phenomenon)

        service.undo(bulk_edit)

        expect(noun.reload.phenomenons).not_to include(phenomenon)
        expect(bulk_edit.reload.undone?).to be true
      end
    end

    context "with HABTM remove" do
      let!(:noun) { create :noun, name: "Haus" }
      let!(:phenomenon) { create :phenomenon }

      it "re-adds previously removed associations" do
        noun.phenomenons << phenomenon

        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "phenomenons",
          operation: "remove",
          values: [phenomenon.id.to_s]
        )

        expect(noun.reload.phenomenons).to be_empty

        service.undo(bulk_edit)

        expect(noun.reload.phenomenons).to include(phenomenon)
      end
    end

    context "with belongs_to" do
      let!(:noun) { create :noun, name: "Haus" }
      let!(:hierarchy) { create :hierarchy }

      it "restores previous value" do
        noun.update!(hierarchy: hierarchy)

        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "hierarchy_id",
          operation: "set",
          values: [nil]
        )

        expect(noun.reload.hierarchy).to be_nil

        service.undo(bulk_edit)

        expect(noun.reload.hierarchy).to eq(hierarchy)
      end
    end

    context "with boolean" do
      let!(:noun) { create :noun, name: "Haus", prototype: true }

      it "restores previous value" do
        bulk_edit = service.execute(
          word_ids: [noun.id],
          field: "prototype",
          operation: "set",
          values: ["false"]
        )

        expect(noun.reload.prototype).to be false

        service.undo(bulk_edit)

        expect(noun.reload.prototype).to be true
      end
    end

    it "raises error when already undone" do
      bulk_edit = create(:bulk_edit, undone: true)

      expect { service.undo(bulk_edit) }.to raise_error("Already undone")
    end
  end
end
