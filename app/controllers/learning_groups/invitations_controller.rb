# frozen_string_literal: true

module LearningGroups
  class InvitationsController < ApplicationController
    load_resource :school
    load_resource :learning_group, through: :school

    def show
      authorize! :accept_invitation, @learning_group

      return render status: :unauthorized if params[:token] != @learning_group.invitation_token

      LearningGroupMembership.create!(
        student: current_user,
        learning_group: @learning_group,
        access: "granted"
      )

      redirect_to [@school, @learning_group], notice: t("learning_groups.invitation.accepted", name: @learning_group.name)
    end

    def create
      authorize! :invite, @learning_group

      @learning_group.transaction do
        @learning_group.update!(invitable: true)
        @learning_group.regenerate_invitation_token
      end

      redirect_to [@school, @learning_group]
    end

    def destroy
      authorize! :invite, @learning_group

      @learning_group.transaction do
        @learning_group.update!(
          invitable: false,
          invitation_token: nil
        )
      end

      redirect_to [@school, @learning_group]
    end
  end
end
