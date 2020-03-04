# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  acn        :string
#  address_1  :string
#  address_2  :string
#  city       :string
#  contact_no :string
#  country    :string
#  name       :string
#  post_code  :integer
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ApplicationRecord
  has_many :users
  has_many :employee_listings, as: :lister

  COMPANY_STATES = ["NSW", "VIC", "QLD", "WA", "SA", "NT", "ACT", "TAS"]
  EMPLOYEE_COUNTRIES = ["Australia"]

  def creator
    users.where.not(user_type: nil).first
  end
end
