# == Schema Information
#
# Table name: employee_listings
#
#  id                                    :bigint           not null, primary key
#  address_1                             :string
#  address_2                             :string
#  available_in_holidays                 :boolean          default(FALSE)
#  birth_year                            :integer
#  city                                  :string
#  country                               :string
#  deactivated                           :boolean          default(FALSE)
#  deactivation_feedback                 :text
#  deactivation_reason                   :integer          default(7)
#  end_publish_date                      :date
#  first_name                            :string
#  gender                                :string
#  has_vehicle                           :boolean          default(FALSE)
#  holiday_price                         :decimal(, )      default(0.0)
#  last_name                             :string
#  lister_type                           :string
#  listing_step                          :integer
#  minimum_working_hours                 :integer
#  optional_comments                     :text
#  other_residency_status                :string
#  post_code                             :integer
#  profile_picture_content_type          :string
#  profile_picture_file_name             :string
#  profile_picture_file_size             :bigint
#  profile_picture_updated_at            :datetime
#  published                             :boolean          default(FALSE)
#  residency_status                      :string
#  skill_description                     :text
#  start_publish_date                    :date
#  state                                 :string
#  tfn                                   :string
#  title                                 :string
#  verification_back_image_content_type  :string
#  verification_back_image_file_name     :string
#  verification_back_image_file_size     :bigint
#  verification_back_image_updated_at    :datetime
#  verification_front_image_content_type :string
#  verification_front_image_file_name    :string
#  verification_front_image_file_size    :bigint
#  verification_front_image_updated_at   :datetime
#  verification_type                     :string
#  weekday_price                         :decimal(, )      default(0.0)
#  weekend_price                         :decimal(, )      default(0.0)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  classification_id                     :integer
#  lister_id                             :integer
#

class EmployeeListing < ApplicationRecord
  scope :active, -> { where(deactivated: false) }
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  attr_accessor :other_weekday_price
  attr_accessor :other_weekend_price
  attr_accessor :other_holiday_price

  belongs_to :lister, polymorphic: true
  belongs_to :classification, optional: true
  has_many :employee_listing_languages
  has_many :languages, through: :employee_listing_languages
  has_many :listing_availabilities
  has_many :employee_listing_slots
  has_many :slots, through: :employee_listing_slots
  has_many :relevant_documents
  has_many :employee_skills
  has_many :transactions
  has_many :bookings, through: :transactions
  has_many :conversations, dependent: :destroy
  has_many :messages, through: :conversations
  has_attached_file :profile_picture
  validates_attachment_content_type :profile_picture, content_type: /\Aimage\/.*\z/
  has_attached_file :verification_front_image
  validates_attachment_content_type :verification_front_image, content_type: /\Aimage\/.*\z/
  has_attached_file :verification_back_image
  validates_attachment_content_type :verification_back_image, content_type: /\Aimage\/.*\z/
  geocoded_by :address
  after_validation :geocode
  def address
    [address_1, address_2, city, state, country, post_code].compact.join(', ')
  end


  EMPLOYEE_STATES = [ "NSW", "VIC", "QLD", "WA", "SA", "NT", "ACT", "TAS" ]
  EMPLOYEE_COUNTRIES = [ "Australia" ]
  EMPLOYEE_COUNTRIES_WITH_CODE = [ ["Australia", "AU"] ]
  EMPLOYEE_RESIDENCY_STATUSES = [ "Permanent Resident/Citizen", "Family/Partner Visa", "Student Visa", "Other Visas" ]
  EMPLOYEE_VERIFICATION_TYPES = [ "Australian Driver Licence", "Australian Passport", "Australian Citizenship Certificate",
                                  "Overseas Passport", "Australian Birth Certificate", "Australian Issued Photo ID", "Others" ]
  PRICES = [ ["$20 / Hour", 20.0], ["$30 / Hour", 30.0], ["$40 / Hour", 40.0], ["$50 / Hour", 50.0], ["$60 / Hour", 60.0],
              ["$70 / Hour", 70.0], ["$80 / Hour", 80.0], ["$90 / Hour", 90.0], ["$100 / Hour", 100.0] ]
  MINIMUM_WORKING_HOURS = [ ["None", 0], ["2 Hours", 2], ["4 Hours", 4], ["6 Hours", 6], ["8 Hours", 8], ["10 Hours", 10],
                            ["20 Hours (approx 1 week part time)", 20], ["40 Hours (approx 1 week full time)", 40] ]
  DEACTIVATION_REASON = [ ["Our company no longer have this employee", 0], ["Our company needs the employee more often now", 1],
                          ["I am the employee and I have found a job elsewhere", 2], ["It's a duplicated listing", 3],
                          ["I have law, confidentiality or policy concerns", 4], ["It takes too much effort", 5],
                          ["I'm a job seeker but I'm not comfortable listing myself for hiring here", 6], ["None of these", 7] ]
  HOURLY_RATES = [ ["$10 / Hour", 10.0], ["$20 / Hour", 20.0], ["$30 / Hour", 30.0], ["$40 / Hour", 40.0], ["$50 / Hour", 50.0], ["$60 / Hour", 60.0],
              ["$70 / Hour", 70.0], ["$80 / Hour", 80.0], ["$90 / Hour", 90.0], ["$100 / Hour", 100.0], ["$150 / Hour", 150.0], ["$200 / Hour", 200.0],
              ["$250 / Hour", 250.0], ["$300 / Hour", 300.0], ["$350 / Hour", 350.0], ["$400 / Hour", 400.0], ["$450 / Hour", 450.0], ["$500 / Hour", 500.0] ]
  
  AGE = [ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100] 
  def poster
    lister_type.eql?("User") ? self.lister : self.lister.creator
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
