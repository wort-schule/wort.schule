class CreateReviewers < ActiveRecord::Migration[7.1]
  def change
    create_view :reviewers
  end
end
