# frozen_string_literal: true

class LearningGroup < ApplicationRecord
  extend Enumerize

  default_scope { order(:name) }

  enumerize :font, in: Fonts.keys

  belongs_to :owner, foreign_key: :user_id, class_name: "User"

  belongs_to :word_view_setting, optional: true

  has_many :learning_group_memberships, dependent: :destroy
  has_many :granted_learning_group_memberships, -> { with_access("granted") }, class_name: "LearningGroupMembership"
  has_many :users, through: :granted_learning_group_memberships
  has_many :learning_pleas
  has_many :lists, through: :learning_pleas

  has_secure_token :invitation_token, length: 42

  scope :with_group_admin, ->(user) {
                             LearningGroup.union(
                               where(owner: user),
                               LearningGroup.where(id: includes(:learning_group_memberships).where(learning_group_memberships: {role: "group_admin", user:}).select(:id))
                             )
                           }

  validates_presence_of :name
  validate :accessible_word_view_setting

  after_save :update_word_view_setting

  private

  def update_word_view_setting
    users.update_all(word_view_setting_id: word_view_setting.id) if word_view_setting_previously_changed?
  end

  def accessible_word_view_setting
    if word_view_setting&.visibility&.private? && word_view_setting&.owner != owner
      errors.add(:word_view_setting_id, :invalid)
    end
  end
end
