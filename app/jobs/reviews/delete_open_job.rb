# frozen_string_literal: true

module Reviews
  class DeleteOpenJob < ApplicationJob
    def perform
      scope.in_batches.destroy_all
    end

    def scope
      ChangeGroup
        .where(state: :waiting_for_review)
    end
  end
end
