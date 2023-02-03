# frozen_string_literal: true

RSpec.describe LearningGroup do
  let!(:requested_user) { create :guest }
  let!(:granted_user) { create :guest }
  let!(:learning_group) { create :learning_group }
  let!(:granted_membership) { create :learning_group_membership, user: granted_user, learning_group:, access: "granted" }
  let!(:requested_membership) { create :learning_group_membership, user: requested_user, learning_group:, access: "requested" }

  it "includes only granted memberships" do
    expect(learning_group.users).to include granted_user
    expect(learning_group.users).not_to include requested_user
  end

  describe "#destroy" do
    it "deletes all memberships" do
      expect(granted_user.learning_groups).to match [learning_group]
      expect(learning_group.users).to match_array [granted_user]

      learning_group.destroy

      granted_user.reload
      expect(granted_user.learning_groups).to eq []

      expect { learning_group.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
