# frozen_string_literal: true

RSpec.describe "user account generation" do
  let(:admin) { create :admin }

  before do
    login_as admin
  end

  let!(:learning_group) { create :learning_group }

  it "creates user accounts" do
    generated_accounts_count = User.all.to_a.count { |user| user.generated_account? }

    visit learning_group_path(learning_group)
    click_on t("learning_groups.show.generate_accounts")

    fill_in t("learning_groups.user_generations.new.amount"), with: 2
    expect do
      click_on t("actions.create")
    end.to change(User, :count).by(2)

    expect(User.all.to_a.count { |user| user.generated_account? }).to eq generated_accounts_count + 2
  end
end
