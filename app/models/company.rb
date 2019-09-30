# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string
#  acn        :string
#  address_1  :string
#  address_2  :string
#  city       :string
#  state      :string
#  country    :string
#  post_code  :integer
#  contact_no :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ApplicationRecord
  has_many :users
  has_many :employee_listings, as: :lister
end
