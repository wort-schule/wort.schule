# Preview all emails at http://localhost:3000/rails/mailers/learning_group
class LearningGroupPreview < ActionMailer::Preview
  def invite
    LearningGroupMailer.with(
      learning_group_name: "Unterwuppenthaler Buchstabenkenner",
      user: FactoryBot.build(:user)
    ).invite
  end
end
