# frozen_string_literal: true

class User < ApplicationRecord
  self.inheritance_column = :role

  extend Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable

  belongs_to :word_view_setting, optional: true

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [64, 64]
  end

  has_many :themes
  has_many :lists

  has_many :learning_group_memberships, dependent: :destroy
  has_many :learning_groups, through: :learning_group_memberships
  has_many :flashcard_lists, -> { where.not(flashcard_section: nil).order(:flashcard_section) }, class_name: "List", foreign_key: :user_id, dependent: :destroy

  enumerize :role, in: %w[Guest Lecturer Admin]

  after_create :setup_flashcards

  def full_name
    [first_name, last_name].select(&:present?).join(" ")
  end

  def to_s
    full_name.presence || email.gsub("@#{Rails.application.config.generated_account_domain}", "")
  end

  def first_flashcard_list
    flashcard_list(Flashcards::SECTIONS.first)
  end

  def flashcard_list(flashcard_section)
    flashcard_lists.find_by(flashcard_section:)
  end

  def word_in_flashcards?(word)
    flashcard_lists.joins(:words).where(words: {id: word.id}).exists?
  end

  def active_for_authentication?
    send_confirmation_instructions if !confirmed? && confirmation_token.blank?

    super
  end

  def generated_account?
    email.ends_with?("@#{Rails.application.config.generated_account_domain}")
  end

  def may_become_group_admin?(membership)
    membership.access.granted? && !generated_account?
  end

  def last_learning_group
    learning_group_memberships
      .with_access(:granted)
      .order(updated_at: :desc)
      .first
      &.learning_group
  end

  def review_attributes=(new_value)
    write_attribute :review_attributes, (new_value || []).compact_blank
  end

  def review_attributes_without_types
    review_attributes.map do |attribute_with_type|
      _type, attribute = attribute_with_type.split(".")

      attribute
    end.flatten.uniq
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
