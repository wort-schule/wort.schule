class School < ApplicationRecord
  has_many :teaching_assignments
  has_many :teachers, through: :teaching_assignments
  has_many :learning_groups

  validates_presence_of :name
  validates_presence_of :zip_code
  validates_presence_of :city
  validates_presence_of :country
  validates :homepage_url, url: {allow_blank: true}
  validates :email, allow_blank: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates_plausible_phone :phone_number
  validates_plausible_phone :fax_number

  phony_normalize :phone_number
  phony_normalize :fax_number

  before_validation :ensure_homepage_scheme

  def to_s
    name
  end

  def city_with_zip_code
    [zip_code, city].select(&:present?).join(" ")
  end

  def country_name
    country_properties = ISO3166::Country[country]

    return "" if country_properties.blank?

    country_properties.translations[I18n.locale.to_s] ||
      country_properties&.common_name ||
      country_properties&.iso_short_name
  end

  private

  def ensure_homepage_scheme
    has_http_scheme = homepage_url&.downcase&.start_with?("http")

    self.homepage_url = "https://#{homepage_url}" if homepage_url.present? && !has_http_scheme
  end
end
