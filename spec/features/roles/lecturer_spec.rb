# frozen_string_literal: true

RSpec.describe "as a lecturer" do
  let(:lecturer) { create :lecturer }

  before do
    login_as lecturer
  end

  describe "learning groups" do
    context "without groups" do
      before do
        visit root_path

        visit navigation_path
        click_on LearningGroup.model_name.human(count: 2), match: :first
      end

      it "creates a group" do
        click_on t("learning_groups.index.new")

        fill_in LearningGroup.human_attribute_name(:name), with: "Sommercamp"

        expect do
          click_on t("helpers.submit.create")
        end.to change(LearningGroup, :count).by 1

        learning_group = LearningGroup.last
        expect(learning_group.name).to eq "Sommercamp"
        expect(learning_group.owner).to eq lecturer
      end
    end

    context "with an existing group" do
      let!(:learning_group) { create :learning_group, owner: lecturer }
      let(:new_name) { "Neuer Gruppenname" }

      before do
        visit learning_groups_path
      end

      it "edits a group" do
        expect(learning_group.name).not_to eq new_name

        click_on learning_group.name

        click_on t("actions.edit")
        fill_in LearningGroup.human_attribute_name(:name), with: new_name

        expect do
          click_on t("helpers.submit.update")
          learning_group.reload
        end.to change(learning_group, :name).from(learning_group.name).to(new_name)
      end

      it "deletes a group" do
        click_on learning_group.name
        click_on t("actions.edit")

        expect do
          click_on t("actions.delete")
        end.to change(LearningGroup, :count).by(-1)

        expect { learning_group.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      context "with users" do
        let!(:user) { create :guest }

        context "when a user is a member" do
          let!(:learning_group_membership) { create :learning_group_membership, learning_group:, user:, access: "granted" }

          it "removes a user" do
            click_on learning_group.name

            expect do
              within "##{dom_id(user)}" do
                click_on t("actions.remove")
              end
            end.to change(LearningGroupMembership, :count).by(-1)

            expect(user.learning_groups).not_to include learning_group
            expect(learning_group.users).not_to include user
          end
        end
      end
    end
  end
end
