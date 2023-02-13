class User < ApplicationRecord
  self.inheritance_column = :role

  extend Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [64, 64]
  end

  has_many :themes
  has_many :lists

  has_many :learning_group_memberships, dependent: :destroy
  has_many :learning_groups, through: :learning_group_memberships
  has_many :flashcard_lists, -> { where.not(flashcard_section: nil).order(:flashcard_section) }, class_name: "List", foreign_key: :user_id, dependent: :destroy

  belongs_to :theme_noun, class_name: "Theme", optional: true
  belongs_to :theme_verb, class_name: "Theme", optional: true
  belongs_to :theme_adjective, class_name: "Theme", optional: true
  belongs_to :theme_function_word, class_name: "Theme", optional: true

  enumerize :role, in: %w[Guest Lecturer Admin]

  after_create :setup_flashcards

  def full_name
    [first_name, last_name].select(&:present?).join(" ")
  end

  def to_s
    full_name.presence || email
  end

  def first_flashcard_list
    flashcard_list(Flashcards::SECTIONS.first)
  end

  def flashcard_list(flashcard_section)
    flashcard_lists.find_by(flashcard_section:)
  end

  def word_in_flashcards?(word)
    flashcard_lists.joins(:words).exists?("words.id": word.id)
  end

  private

  def setup_flashcards
    Flashcards::SECTIONS.each do |section|
      List.create!(
        user: self,
        flashcard_section: section,
        visibility: :private
      )
    end
  end
end
