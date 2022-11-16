# frozen_string_literal: true

RSpec.describe "learning groups" do
  context "as a teacher" do
    let(:teacher) { create :teacher }
    let(:school) { create :school }
    let!(:teaching_assignment) { create :teaching_assignment, teacher:, school: }
    let!(:learning_group) { create :learning_group, teacher:, school: }

    before do
      login_as teacher
    end

    it "activates invitations" do
      old_token = learning_group.invitation_token
      expect(learning_group.invitable).to be false

      visit school_learning_group_path(school, learning_group)

      click_on t("learning_groups.invitation.activate")
      expect(page).to have_content t("learning_groups.invitation.active")

      learning_group.reload
      expect(learning_group.invitation_token).to be_present
      expect(learning_group.invitation_token).not_to eq old_token
      expect(learning_group.invitable).to be true
    end

    context "with active invitations" do
      let!(:learning_group) { create :learning_group, teacher:, school:, invitable: true }

      it "deactivates invitations" do
        expect(learning_group.invitable).to be true

        visit school_learning_group_path(school, learning_group)

        click_on t("learning_groups.invitation.deactivate")
        expect(page).to have_content t("learning_groups.invitation.activate")

        learning_group.reload
        expect(learning_group.invitation_token).to be nil
        expect(learning_group.invitable).to be false
      end
    end

    it "adds a word list" do
      word_list = create :list, user: teacher, visibility: :public

      visit school_learning_group_path(school, learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")

      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
    end
  end

  context "as a student" do
    let(:teacher) { create :teacher }
    let(:school) { create :school }
    let!(:teaching_assignment) { create :teaching_assignment, teacher:, school: }
    let!(:learning_group) { create :learning_group, teacher:, school:, invitable: true }
    let(:student) { create :student }

    it "accepts an invitation" do
      expect(learning_group.students).not_to include student

      login_as teacher
      visit school_learning_group_path(school, learning_group)

      url = find('input[name="invitation_url"]').value

      login_as student
      visit url

      expect(page).to have_content learning_group.name
      learning_group.reload
      expect(learning_group.students).to include student
    end

    it "requests access" do
      login_as student
      visit school_path(school)
      click_on learning_group.name

      expect do
        click_on t("learning_groups.show.request_access")
      end.to change(LearningGroupMembership, :count).by 1

      expect(page).to have_content t("notices.learning_group_memberships.access_requested")
      membership = LearningGroupMembership.last
      expect(membership.learning_group).to eq learning_group
      expect(membership.student).to eq student
      expect(membership.access).to eq "requested"

      # Accept membership
      login_as teacher
      visit school_learning_group_path(school, learning_group)
      click_on t("learning_groups.show.accept")

      membership.reload
      expect(membership.access).to eq "granted"
    end
  end
end
