# frozen_string_literal: true

module LearningGroupMemberships
  class RequestsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :learning_group, through: :school
    load_resource :learning_group_membership, through: :learning_group, parent: false, id_param: :learning_group_membership_id

    def create
      authorize! :create, :learning_group_membership_requests

      @learning_group_membership.assign_attributes(
        student: Student.find(current_user.id),
        access: "requested"
      )

      notice = if @learning_group_membership.save
        t("notices.learning_group_memberships.access_requested")
      else
        t("notices.learning_group_memberships.access_requested_error")
      end

      redirect_to [@school, @learning_group], notice:
    end

    def accept
      authorize! :accept, :learning_group_membership_requests

      notice = if @learning_group_membership.update(access: "granted")
        t("notices.learning_group_memberships.accepted")

      else
        t("notices.learning_group_memberships.accepted_error")
      end

      redirect_to [@school, @learning_group], notice:
    end

    def reject
      authorize! :reject, :learning_group_membership_requests

      notice = if @learning_group_membership.update(access: "rejected")
        t("notices.learning_group_memberships.rejected")
      else
        t("notices.learning_group_memberships.rejected_error")
      end

      redirect_to [@school, @learning_group], notice:
    end
  end
end
