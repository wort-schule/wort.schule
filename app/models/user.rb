class User < ApplicationRecord
  extend Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [64, 64]
  end

  has_many :themes

  enumerize :role, in: %w[Guest Student Teacher Admin]

  def full_name
    [first_name, last_name].select(&:present?).join(" ")
  end

  def to_s
    full_name
  end

  def teacher?
    role.Teacher?
  end

  def student?
    role.Student?
  end
end
