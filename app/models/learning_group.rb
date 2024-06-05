class LearningGroup < ApplicationRecord
  extend Enumerize

  default_scope { order(:name) }

  enumerize :font, in: Fonts.keys

  belongs_to :owner, foreign_key: :user_id, class_name: "User"

  belongs_to :theme_noun, class_name: "Theme", optional: true
  belongs_to :theme_verb, class_name: "Theme", optional: true
  belongs_to :theme_adjective, class_name: "Theme", optional: true
  belongs_to :theme_function_word, class_name: "Theme", optional: true

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

  after_save :update_themes

  private

  def update_themes
    Theme::WORD_TYPES.each do |word_type|
      users.update_all("theme_#{word_type}_id": send(:"theme_#{word_type}_id")) if (previous_changes.keys & ["theme_#{word_type}_id"]).any?
    end
  end
end
