# frozen_string_literal: true

RSpec.describe "as a teacher" do
  let(:teacher) { create :teacher }
  let(:school) { create :school }
  let!(:teaching_assignment) { create :teaching_assignment, teacher:, school: }

  before do
    login_as teacher
  end

  describe "learning groups" do
    context "without groups" do
      before do
        visit root_path

        within ".ci-navigation" do
          click_on School.model_name.human(count: 2), match: :first
        end
        click_on school.name
      end

      it "creates a group" do
        click_on t("learning_groups.index.new")

        fill_in LearningGroup.human_attribute_name(:name), with: "Sommercamp"

        expect do
          click_on t("helpers.submit.create")
        end.to change(LearningGroup, :count).by 1

        learning_group = LearningGroup.last
        expect(learning_group.name).to eq "Sommercamp"
        expect(learning_group.teacher).to eq teacher
        expect(learning_group.school).to eq school
      end
    end

    context "with an existing group" do
      let!(:learning_group) { create :learning_group, teacher:, school: }
      let(:new_name) { "Neuer Gruppenname" }

      before do
        visit school_path(school)
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

      context "with students" do
        let!(:student) { create :student }

        it "adds a student" do
          click_on learning_group.name

          click_on t("learning_groups.show.assign_student")

          expect do
            within "##{dom_id(student)}" do
              click_on t("learning_group_memberships.new.assign")
            end
          end.to change(LearningGroupMembership, :count).by 1

          expect(student.learning_groups).to include learning_group
          expect(learning_group.students).to include student
        end

        context "when a student is a member" do
          let!(:learning_group_membership) { create :learning_group_membership, learning_group:, student:, access: "granted" }

          it "removes a student" do
            click_on learning_group.name

            expect do
              within "##{dom_id(student)}" do
                click_on t("actions.remove")
              end
            end.to change(LearningGroupMembership, :count).by(-1)

            expect(student.learning_groups).not_to include learning_group
            expect(learning_group.students).not_to include student
          end
        end
      end
    end
  end
end
