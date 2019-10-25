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

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
