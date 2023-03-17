# frozen_string_literal: true

RSpec.describe "learning groups" do
  context "as a lecturer" do
    let(:lecturer) { create :lecturer }
    let!(:learning_group) { create :learning_group, owner: lecturer }

    before do
      login_as lecturer
    end

    it "activates invitations" do
      old_token = learning_group.invitation_token
      expect(learning_group.invitable).to be false

      visit learning_group_path(learning_group)

      click_on t("learning_groups.invitation.activate")
      expect(page).to have_content t("learning_groups.invitation.active")

      learning_group.reload
      expect(learning_group.invitation_token).to be_present
      expect(learning_group.invitation_token).not_to eq old_token
      expect(learning_group.invitable).to be true
    end

    context "with active invitations" do
      let!(:learning_group) { create :learning_group, owner: lecturer, invitable: true }

      it "deactivates invitations" do
        expect(learning_group.invitable).to be true

        visit learning_group_path(learning_group)

        click_on t("learning_groups.invitation.deactivate")
        expect(page).to have_content t("learning_groups.invitation.activate")

        learning_group.reload
        expect(learning_group.invitation_token).to be nil
        expect(learning_group.invitable).to be false
      end
    end

    it "invites a user by email address" do
      new_user = create :user

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_user")

      fill_in t("learning_group_memberships.new.email_or_username"), with: new_user.email
      expect do
        click_on t("learning_group_memberships.new.assign")
      end.to change(learning_group.learning_group_memberships, :count).by(1)

      expect(page).to have_current_path learning_group_path(learning_group)
      expect(learning_group.learning_group_memberships.find_by(user: new_user).access).to eq "invited"
      expect(page).to have_content new_user.full_name
    end

    it "invites a user by username" do
      username = "abcd"
      new_user = create :user, email: "#{username}@user.wort.schule"

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_user")

      fill_in t("learning_group_memberships.new.email_or_username"), with: username
      expect do
        click_on t("learning_group_memberships.new.assign")
      end.to change(learning_group.learning_group_memberships, :count).by(1)

      expect(page).to have_current_path learning_group_path(learning_group)
      expect(learning_group.learning_group_memberships.find_by(user: new_user).access).to eq "invited"
      expect(page).to have_content new_user.full_name
    end

    it "adds a word list" do
      word_list = create :list, user: lecturer, visibility: :public

      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.assign_list")
      expect(page).to have_content t("learning_pleas.new.title")

      click_on t("learning_pleas.new.assign")

      expect(learning_group.lists).to match_array [word_list]
    end
  end

  context "as a user" do
    let(:lecturer) { create :lecturer }
    let!(:learning_group) { create :learning_group, owner: lecturer, invitable: true }
    let(:user) { create :guest }

    it "accepts an invitation" do
      expect(learning_group.users).not_to include user

      login_as lecturer
      visit learning_group_path(learning_group)

      url = find('input[name="invitation_url"]').value

      login_as user
      visit url

      expect(page).to have_content learning_group.name
      learning_group.reload
      expect(learning_group.users).to include user
    end

    it "requests access" do
      login_as user
      visit learning_groups_path
      click_on learning_group.name

      expect do
        click_on t("learning_groups.show.request_access")
      end.to change(LearningGroupMembership, :count).by 1

      expect(page).to have_content t("notices.learning_group_memberships.access_requested")
      membership = LearningGroupMembership.last
      expect(membership.learning_group).to eq learning_group
      expect(membership.user).to eq user
      expect(membership.access).to eq "requested"

      # Accept membership
      login_as lecturer
      visit learning_group_path(learning_group)
      click_on t("learning_groups.show.accept")

      membership.reload
      expect(membership.access).to eq "granted"
    end
  end
end
