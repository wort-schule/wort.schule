class LearningGroup < ApplicationRecord
  default_scope { order(:name) }

  belongs_to :teacher
  belongs_to :school

  belongs_to :theme_noun, class_name: "Theme", optional: true
  belongs_to :theme_verb, class_name: "Theme", optional: true
  belongs_to :theme_adjective, class_name: "Theme", optional: true
  belongs_to :theme_function_word, class_name: "Theme", optional: true

  has_many :learning_group_memberships, dependent: :destroy
  has_many :granted_learning_group_memberships, -> { with_access("granted") }, class_name: "LearningGroupMembership"
  has_many :students, through: :granted_learning_group_memberships

  has_secure_token :invitation_token, length: 42

  validates_presence_of :name

  after_save :update_themes

  private

  def update_themes
    Theme::WORD_TYPES.each do |word_type|
      students.update_all("theme_#{word_type}_id": send("theme_#{word_type}_id")) if (previous_changes.keys & ["theme_#{word_type}_id"]).any?
    end
  end
end
