class LearningGroupMailer < ApplicationMailer
  def invite
    @learning_group_name = params[:learning_group_name]
    @user = params[:user]
    @full_name = @user.full_name.presence || @user.email

    mail to: @user.email, subject: t(".subject", name: @learning_group_name)
  end
end
