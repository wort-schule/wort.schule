# frozen_string_literal: true

RSpec.describe "schools" do
  let(:admin) { create :user, role: "Admin" }

  before do
    login_as admin
    visit root_path
  end

  it "creates a school" do
    within ".ci-navigation" do
      click_on School.model_name.human(count: 2)
    end

    click_on t("schools.index.new")

    fill_in School.human_attribute_name(:name), with: "Mittelschule Musterhausen"

    expect do
      click_on t("helpers.submit.create")
    end.to change(School, :count).by(1)

    school = School.last
    expect(school.name).to eq "Mittelschule Musterhausen"
  end

  context "with an existing school" do
    let!(:school) { create :school, name: "Mittelschule Musterhausen" }

    it "shows all schools" do
      within ".ci-navigation" do
        click_on School.model_name.human(count: 2)
      end

      expect(page).to have_selector "h1", text: School.model_name.human(count: 2)
      expect(page).to have_content school.name
    end

    it "edits a school" do
      expect(school.name).to eq school.name

      within ".ci-navigation" do
        click_on School.model_name.human(count: 2)
      end

      expect(page).to have_selector "h1", text: School.model_name.human(count: 2)
      find("##{dom_id(school)}").click

      click_on t("actions.edit")

      fill_in School.human_attribute_name(:name), with: "Oberstufe Mustersee"
      click_on t("helpers.submit.update")

      school.reload
      expect(school.name).to eq "Oberstufe Mustersee"
    end

    it "deletes a school" do
      within ".ci-navigation" do
        click_on School.model_name.human(count: 2)
      end

      expect(page).to have_selector "h1", text: School.model_name.human(count: 2)
      find("##{dom_id(school)}").click

      click_on t("actions.edit")

      expect do
        click_on t("actions.delete")
      end.to change(School, :count).by(-1)
    end

    context "with teachers" do
      let!(:teacher) { create :user, role: "Teacher" }

      it "assigns a teacher to the school" do
        visit school_path(school)

        click_on t("schools.show.assign_teacher")

        expect(page).to have_content teacher.decorate.display_name

        expect do
          click_on t("teaching_assignments.new.assign")
        end.to change(TeachingAssignment, :count).by(1)

        assignment = TeachingAssignment.last
        expect(assignment.school).to eq school
        expect(assignment.teacher).to eq teacher
      end
    end

    context "with an assigned teacher" do
      let!(:teacher) { create :user, role: "Teacher" }
      let!(:teaching_assignment) { create :teaching_assignment, teacher:, school: }

      it "removes a teacher from the school" do
        visit school_path(school)

        expect do
          click_on t("actions.remove")
        end.to change(school.teachers, :count).by(-1)
      end
    end
  end
end
