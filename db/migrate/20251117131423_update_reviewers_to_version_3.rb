class UpdateReviewersToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :reviewers, version: 3, revert_to_version: 2
  end
end
