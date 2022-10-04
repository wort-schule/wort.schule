# frozen_string_literal: true

RSpec.describe LearningGroup do
  let!(:school) { create :school }
  let!(:requested_student) { create :student }
  let!(:granted_student) { create :student }
  let!(:learning_group) { create :learning_group }
  let!(:granted_membership) { create :learning_group_membership, student: granted_student, learning_group:, access: "granted" }
  let!(:requested_membership) { create :learning_group_membership, student: requested_student, learning_group:, access: "requested" }

  it "includes only granted memberships" do
    expect(learning_group.students).to include granted_student
    expect(learning_group.students).not_to include requested_student
  end

  describe "#destroy" do
    it "deletes all memberships" do
      expect(granted_student.learning_groups).to match [learning_group]
      expect(learning_group.students).to match_array [granted_student]

      learning_group.destroy

      granted_student.reload
      expect(granted_student.learning_groups).to eq []

      expect { learning_group.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
