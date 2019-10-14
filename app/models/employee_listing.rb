# == Schema Information
#
# Table name: employee_listings
#
#  id                                    :bigint           not null, primary key
#  classification_id                     :integer
#  title                                 :string
#  first_name                            :string
#  last_name                             :string
#  tfn                                   :string
#  birth_year                            :integer
#  address_1                             :string
#  address_2                             :string
#  city                                  :string
#  state                                 :string
#  country                               :string
#  post_code                             :integer
#  residency_status                      :string
#  other_residency_status                :string
#  verification_type                     :string
#  gender                                :string
#  has_vehicle                           :boolean          default(FALSE)
#  skill_description                     :text
#  optional_comments                     :text
#  published                             :boolean          default(FALSE)
#  lister_id                             :integer
#  lister_type                           :string
#  listing_step                          :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  available_in_holidays                 :boolean          default(FALSE)
#  weekday_price                         :decimal(, )
#  holiday_price                         :decimal(, )
#  minimum_working_hours                 :integer
#  start_publish_date                    :date
#  end_publish_date                      :date
#  weekend_price                         :decimal(, )
#  profile_picture_file_name             :string
#  profile_picture_content_type          :string
#  profile_picture_file_size             :bigint
#  profile_picture_updated_at            :datetime
#  verification_front_image_file_name    :string
#  verification_front_image_content_type :string
#  verification_front_image_file_size    :bigint
#  verification_front_image_updated_at   :datetime
#  verification_back_image_file_name     :string
#  verification_back_image_content_type  :string
#  verification_back_image_file_size     :bigint
#  verification_back_image_updated_at    :datetime
#

class EmployeeListing < ApplicationRecord
  attr_accessor :other_weekday_price
  attr_accessor :other_weekend_price
  attr_accessor :other_holiday_price

  belongs_to :lister, polymorphic: true
  has_many :employee_listing_languages
  has_many :languages, through: :employee_listing_languages
  has_many :listing_availabilities
  has_many :employee_listing_slots
  has_many :slots, through: :employee_listing_slots
  has_many :relevant_documents
  has_attached_file :profile_picture
  validates_attachment_content_type :profile_picture, content_type: /\Aimage\/.*\z/
  has_attached_file :verification_front_image
  validates_attachment_content_type :verification_front_image, content_type: /\Aimage\/.*\z/
  has_attached_file :verification_back_image
  validates_attachment_content_type :verification_back_image, content_type: /\Aimage\/.*\z/

  EMPLOYEE_STATES = ["NSW", "VIC", "QLD", "WA", "SA", "NT", "ACT", "TAS"]
  EMPLOYEE_COUNTRIES = ["Australia"]
  EMPLOYEE_RESIDENCY_STATUSES = ["Permanent Resident/Citizen", "Family/Partner Visa", "Student Visa", "Other Visas"]
  EMPLOYEE_VERIFICATION_TYPES = ["Australian Driver Licence", "Australian Passport", "Australian Citizenship Certificate", "Overseas Passport", "Australian Birth Certificate", "Australian Issued Photo ID", "Others"]
  PRICES = [ ["$20 / Hour", 20], ["$30 / Hour", 30], ["$40 / Hour", 40], ["$50 / Hour", 50], ["$60 / Hour", 60],
              ["$70 / Hour", 70], ["$80 / Hour", 80], ["$90 / Hour", 90], ["$100 / Hour", 100] ]
  MINIMUM_WORKING_HOURS = [ ["None", 0], ["2 Hours", 2], ["4 Hours", 4], ["6 Hours", 6], ["8 Hours", 8], ["10 Hours", 10], ["20 Hours (approx 1 week part time)", 20], ["40 Hours (approx 1 week full time)", 40] ]
end
