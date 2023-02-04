# frozen_string_literal: true

module LearningGroups
  class UserGenerationsController < ApplicationController
    load_resource :learning_group

    def new
      authorize! :generate_users, @learning_group
    end

    def create
      authorize! :generate_users, @learning_group

      @accounts = UserAccountGenerator.new.generate(amount: user_generation_params[:amount].to_i)

      @accounts.each do |account|
        user = User.create!(
          email: account[:email],
          password: account[:password]
        )

        user.confirm

        LearningGroupMembership.create!(
          user:,
          learning_group: @learning_group,
          access: "granted"
        )
      end
    end

    private

    def user_generation_params
      params.require(:user_generation).permit(:amount)
    end
  end
end
