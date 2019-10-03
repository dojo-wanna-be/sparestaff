# == Schema Information
#
# Table name: employee_listings
#
#  id                     :bigint           not null, primary key
#  classification_id      :integer
#  title                  :string
#  first_name             :string
#  last_name              :string
#  tfn                    :string
#  birth_year             :integer
#  address_1              :string
#  address_2              :string
#  city                   :string
#  state                  :string
#  country                :string
#  post_code              :integer
#  residency_status       :string
#  other_residency_status :string
#  verification_type      :string
#  gender                 :string
#  has_vehicle            :boolean          default(FALSE)
#  skill_description      :text
#  optional_comments      :text
#  published              :boolean          default(FALSE)
#  lister_id              :integer
#  lister_type            :string
#  listing_step           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class EmployeeListing < ApplicationRecord
  belongs_to :lister, polymorphic: true
  has_many :employee_listing_languages
  has_many :languages, through: :employee_listing_languages

  EMPLOYEE_STATES = ["NSW", "VIC", "QLD", "WA", "SA", "NT", "ACT", "TAS"]
  EMPLOYEE_COUNTRIES = ["Australia"]
  EMPLOYEE_RESIDENCY_STATUSES = ["Permanen Resident/Citizen", "Family/Partner Visa", "Student Visa", "Other Visas"]
  EMPLOYEE_VERIFICATION_TYPES = ["Australian Driver Licence", "Australian Passport", "Australian Citizenship Certificate", "Overseas Passport", "Australian Birth Certificate", "Australian Issued Photo ID", "Others"]
end
