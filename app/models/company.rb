# == Schema Information
#
# Table name: companies
#
#  id                  :bigint           not null, primary key
#  acn                 :string
#  address_1           :string
#  address_2           :string
#  city                :string
#  contact_no          :string
#  country             :string
#  name                :string
#  post_code           :integer
#  probationary_period :integer
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Company < ApplicationRecord
  has_many :users
  has_many :employee_listings, as: :lister

  PROBATIONARY_PERIOD = {
                          "1 month" => 1,
                          "2 months" => 2,
                          "3 months" => 3,
                          "4 months" => 4,
                          "5 months" => 5,
                          "6 months" => 6
                        }

  COMPANY_STATES = ["NSW", "VIC", "QLD", "WA", "SA", "NT", "ACT", "TAS"]
  EMPLOYEE_COUNTRIES = ["Australia"]

  def creator
    users.where.not(user_type: nil).first
  end
end
